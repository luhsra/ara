"""Container for SSE step."""
import graph_tool
import copy
import functools
import numpy as np
from datetime import datetime
import math

import pyllco

from ara.graph import ABBType, Graph, CFGView, CFType
from .step import Step
from .option import Option, String, Choice
from .freertos import Task
from .os_util import SyscallCategory
from ara.util import VarianceDict
from .autosar import Task as AUTOSAR_Task, SyscallInfo, Alarm, Counter
from appl.AUTOSAR.minexample_timing import Timings

from collections import defaultdict
from enum import Enum
from itertools import chain
from graph_tool.topology import dominator_tree, label_out_component


# time counter for performance measures
c_debugging = 0 # in milliseconds

MAX_UPDATES = 2

sse_counter = 0

def debug_time(t_start):
    t_delta = datetime.now() - t_start
    global c_debugging
    c_debugging += t_delta.seconds * 1000 + t_delta.microseconds / 1000

class State:
    def __init__(self, cfg=None, callgraph=None, next_abbs=None):
        self.cfg = cfg
        self.callgraph = callgraph
        if not next_abbs:
            next_abbs = []
        self.next_abbs = next_abbs

        self.instances = graph_tool.Graph()
        self.call = None # call node within the call graph
        self.branch = False # is this state coming from a branch or loop
        self.running = None # what instance (Task or ISR) is currently running

    def __repr__(self):
        ret = f'State(Branch: {self.branch}, '
        abbs = [self.cfg.vp.name[abb] for abb in self.next_abbs]
        ret += ', '.join(abbs)
        return ret + ')'

    def copy(self):
        scopy = State()
        scopy.instances = self.instances.copy()
        for key, value in self.__dict__.items():
            if key == 'instances':
                continue
            setattr(scopy, key, value)
        return scopy


class FlowAnalysis(Step):
    """Base class for all flow analyses.

    Apply the base SSE state search to the CFG. Can be specialized with some
    interface functions.
    """

    def _fill_options(self):
        self.entry_point = Option(name="entry_point",
                                  help="system entry point",
                                  step_name=self.get_name(),
                                  ty=String())
        self.opts.append(self.entry_point)

    def new_vertex(self, sstg, state):
        vertex = sstg.add_vertex()
        sstg.vp.state[vertex] = state
        return vertex

    def _system_semantic(self, state):
        new_states = self._execute(state)
        self._schedule(new_states)
        return new_states

    def run(self, g: Graph):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")
        self._log.info(f"Analyzing entry point: '{entry_label}'")

        self._step_data = self._get_step_data(g, set)

        self._g = g
        self._icfg = CFGView(g.cfg, efilt=g.cfg.ep.type.fa == CFType.icf)
        self._lcfg = CFGView(g.cfg, efilt=g.cfg.ep.type.fa == CFType.lcf)

        self._entry_func = entry_label

        self._init_analysis()

        self.sstg = graph_tool.Graph()
        self.sstg.vertex_properties["state"] = self.sstg.new_vp("object")
        self.sstg.edge_properties["syscall"] = self.sstg.new_ep("object")
        self.sstg.edge_properties["state_list"] = self.sstg.new_ep("object")

        state_vertex = self.new_vertex(self.sstg, self._get_initial_state())

        stack = [state_vertex]

        counter = 0
        while stack:
            self._log.debug(f"Stack {counter:3d}: "
                            f"{[self.sstg.vp.state[v] for v in stack]}")
            state_vertex = stack.pop(0)
            # state = self.sstg.vp.state[state_vertex]
            for n in self._system_semantic(state_vertex):
                if isinstance(n, MetaState):
                    found = False
                    for v in self.sstg.vertices():
                        state = self.sstg.vp.state[v]
                        if state.compare_root_states(n):
                            new_state = v
                            found = True 
                            break
                    if not found:
                        new_state = self.new_vertex(self.sstg, n)
                        e = self.sstg.add_edge(state_vertex, new_state)
                        self.sstg.ep.state_list[e] = GCFGInfo(n.entry_states.copy())
                
                else:
                    new_state = self.new_vertex(self.sstg, n)
                    e = self.sstg.add_edge(state_vertex, new_state) 

                if new_state not in stack or n.updated <= MAX_UPDATES:
                    stack.append(new_state) 
            counter += 1
        self._log.info(f"Analysis needed {counter} iterations.")
        self._log.info(f"Analysis did {sse_counter} SSEs.")

        self._finish(self.sstg)

class GCFGInfo:
    def __init__(self, entry_states):
        self.entry_states = entry_states

class MetaState:
    def __init__(self, cfg=None, instances=None):
        self.cfg = cfg
        self.instances = instances
        self.state_graph = {} # graph of Multistates for each cpu
                              # key: cpu id, value: graph of Multistates
        self.sync_states = {} # list of MultiStates for each cpu, which handle 
                              # a syscall that affects other cpus
                              # key: cpu id, value: list of MultiStates
        self.entry_states = {}  # entry state for each cpu
                                # key: cpu id, value: Multistate
        self.updated = 0 # amount of times this metastate has been updated (timings)

    def __repr__(self):
        ret = ""

        for cpu, graph in self.state_graph.items():
            v = graph.get_vertices()[0]
            state = graph.vp.state[v]
            ret += f"{state} | "
        return ret[:-2]
    
    def basic_copy(self):
        copy = MetaState(self.cfg, self.instances)

        for cpu in self.state_graph:
            copy.state_graph[cpu] = graph_tool.Graph()
            copy.sync_states[cpu] = []
            copy.state_graph[cpu].vertex_properties["state"] = copy.state_graph[cpu].new_vp("object")
            # copy.entry_states[cpu] = None

        return copy
    
    def update_timings(self):
        """Updates the timings in each state in each graph."""

        for cpu, graph in self.state_graph.items():
            v = graph.get_vertices()[0]

            stack = [v]
            found_list = []
            while stack:
                v = stack.pop(0)
                state = graph.vp.state[v]
                found_list.append(state)
                
                task = state.get_scheduled_task()
                if task is not None:
                    abb = state.abbs[task.name]
                    context = None
                    min_time = Timings.get_min_time(state.cfg.vp.name[abb], context)

                    for next_v in graph.vertex(v).out_neighbors():
                        next_state = graph.vp.state[next_v]

                        # check for already found states
                        found = False
                        for s in found_list:
                            if s == next_state:
                                found = True
                                break
                        
                        if not found:
                            stack.append(next_v)
                            
                            # get min and max timings for current abb
                            task = next_state.get_scheduled_task()
                            next_state.times = state.times.copy()
                            
                            if task is not None:
                                abb = next_state.abbs[task.name]
                                context = None
                                
                                max_time = Timings.get_max_time(next_state.cfg.vp.name[abb], context)

                                # update all intervalls
                                for i, intervall in enumerate(state.times):
                                    next_state.times[i] = (intervall[0] + min_time, intervall[1] + max_time)
    
    def compare_root_states(self, other):
        """Compares itself to another metastate, by comparing the root Multistates of each state graph."""
        if not isinstance(other, self.__class__):
            return False
        
        for cpu, g_self in self.state_graph.items():
            if cpu not in other.state_graph:
                return False
            
            v_self = g_self.get_vertices()[0]
            s_self = g_self.vp.state[v_self]

            g_other = other.state_graph[cpu]
            v_other = g_other.get_vertices()[0]
            s_other = g_other.vp.state[v_other]
            
            if s_self != s_other:
                return False

        return True

    def __eq__(self, other):
        if not isinstance(other, self.__class__):
            return False

        # compare state graphs
        for cpu, graph in self.state_graph.items():
            for v in graph.vertices():
                state = graph.vp.state[v]

                if cpu not in other.state_graph:
                    return False
                else:
                    found_state = False
                    for v in other.state_graph[cpu].vertices():
                        state_other = other.state_graph[cpu].vp.state[v]
                        if state == state_other:
                            found_state = True
                            break
                    if not found_state:
                        return False
        
        # compare again in other direction
        for cpu, graph in other.state_graph.items():
            for v in graph.vertices():
                state = graph.vp.state[v]

                if cpu not in self.state_graph:
                    return False
                else:
                    found_state = False
                    for v in self.state_graph[cpu].vertices():
                        state_other = self.state_graph[cpu].vp.state[v]
                        if state == state_other:
                            found_state = True
                            break
                    if not found_state:
                        return False
        return True

class MultiState:
    def __init__(self, cfg=None, instances=None, cpu=0):
        self.cfg = cfg
        self.instances = instances
        self.entry_abbs = {} # entry abbs for each task; key: task name, value: entry abb node
        self.call_nodes = {} # call node of each task (used for handling calls)
                             # key: task name, value: ABB node (call node)
        self.callgraphs = {} # callgraphs for each task; key: task name, value: callgraph
        self.abbs = {} # active ABB per task; key: task name, value: ABB node
        self.activated_tasks = [] # list of activated tasks 

        self.last_syscall = None # syscall that this state originated from (used for building gcfg)
                                 # Type: SyscallInfo 
        self.cpu = cpu
        self.min_time = 0
        self.max_time = 0
        self.times = [(0, 0)] # list of time intervalls this state is valid in
        self.times_merged = [] # same as times list, but without overlapping intervalls
        
    def get_scheduled_task(self):
        if len(self.activated_tasks) >= 1:
            return self.activated_tasks[0]
        else: 
            return None

    def add_time(self, min_time, max_time):
        for i, intervall in enumerate(self.times):
            self.times[i] = (intervall[0] + min_time, intervall[1] + max_time)
        
    
    def merge_times(self):
        """Merges list of time intervalls so that overlapping intervalls are merged into one."""
        self.times_merged.extend(self.times)
        self.times_merged.sort(key=lambda i: i[0])
        while True:
            new_times = self.times_merged.copy()
            for i, time_1 in enumerate(new_times):
                if i != len(new_times) - 1:
                    time_2 = new_times[i + 1]
                    if not time_1[1] < time_2[0]: 
                        intervall = ()  
                        if time_1[1] < time_2[1]:
                            intervall = (time_1[0], time_2[1])
                        else:
                            intervall = (time_1[0], time_1[1])
                        
                        self.times_merged[i] = intervall
                        self.times_merged.pop(i + 1)
                        break
            if new_times == self.times_merged:
                break

    def __repr__(self):
        self.merge_times()
        ret = "["
        scheduled_task = self.get_scheduled_task()
        for task_name, abb in self.abbs.items():
            if scheduled_task is not None and task_name == scheduled_task.name:
                ret += "+"
            if abb is not None:
                ret += self.cfg.vp.name[abb]
            else: 
                ret += "None"
            ret += ", "
        ret = ret[:-2] + "] " + str(self.times_merged)
        return ret

    def __eq__(self, other):
        class_eq = self.__class__ == other.__class__
        abbs_eq = self.abbs == other.abbs
        activated_task_eq = self.activated_tasks == other.activated_tasks
        # multi_ret_eq = self.gcfg_multi_ret == other.gcfg_multi_ret
        return class_eq and abbs_eq and activated_task_eq

    def copy(self):
        scopy = MultiState()

        for key, value in self.__dict__.items():
            setattr(scopy, key, value)
        scopy.instances = self.instances.copy()
        scopy.abbs = self.abbs.copy()
        scopy.activated_tasks = self.activated_tasks.copy()
        scopy.callgraphs = self.callgraphs.copy()
        scopy.call_nodes = self.call_nodes.copy()
        scopy.entry_abbs = self.entry_abbs.copy()
        scopy.times = self.times.copy()
        scopy.times_merged = []

        return scopy

class MultiSSE(FlowAnalysis):
    """Run the MultiCore SSE."""
    # TODOs:


    def get_dependencies(self):
        return ["SysFuncts"]

    def _init_analysis(self):
        pass

    def _get_initial_state(self):
        self.print_tasks()  

        # building initial metastate
        metastate = MetaState(cfg=self._g.cfg, instances=self._g.instances)

        # TODO: get rid of the hardcoded function name
        func_name_start = "AUTOSAR_TASK_FUNC_"
        found_cpus = {}

        # go through all instances and build all initial MultiStates accordingly
        for v in self._g.instances.vertices():
            task = self._g.instances.vp.obj[v]
            state = None
            if isinstance(task, AUTOSAR_Task):
                if task.cpu_id not in found_cpus:
                    # create new MultiState
                    state = MultiState(cfg=self._g.cfg,instances=self._g.instances, cpu=task.cpu_id) 
                    found_cpus[task.cpu_id] = state

                    # add new state to Metastate
                    metastate.state_graph[state.cpu] = graph_tool.Graph()
                    graph = metastate.state_graph[state.cpu]
                    graph.vertex_properties["state"] = graph.new_vp("object")
                    vertex = graph.add_vertex()
                    graph.vp.state[vertex] = state

                    # add empty list to sync_states in Metastate
                    metastate.sync_states[state.cpu] = []
                else:
                    state = found_cpus[task.cpu_id]

                # set entry abb for each task
                func_name = func_name_start + task.name
                entry_func = self._g.cfg.get_function_by_name(func_name)
                entry_abb = self._g.cfg.get_entry_abb(entry_func)
                state.entry_abbs[task.name] = entry_abb

                # setup abbs dict with entry abb for each task
                state.abbs[task.name] = entry_abb

                # set callgraph and entry call node for each task
                state.callgraphs[task.name] = self._g.call_graphs[func_name]
                state.call_nodes[task.name] = self._find_tree_root(self._g.call_graphs[func_name])

                # set multi ret bool to false for all tasks
                # state.gcfg_multi_ret[task.name] = False
                
                # set list of activated tasks
                if task.autostart: 
                    state.activated_tasks.append(task)
        
        # build starting times for each multistate
        for cpu, graph in metastate.state_graph.items():
            v = graph.get_vertices()[0]
            state = graph.vp.state[v]
            abb = state.abbs[state.get_scheduled_task().name]
            context = None
            max_time = Timings.get_max_time(state.cfg.vp.name[abb], context)
            state.times = [(0, max_time)]

        # run single core sse for each cpu
        self.run_sse(metastate)

        return metastate

    def _execute(self, state_vertex):
        metastate = self.sstg.vp.state[state_vertex]
        self._log.info(f"Executing Metastate {state_vertex}: {metastate}")
        new_states = []

        for cpu, sync_list in metastate.sync_states.items():
            for state in sync_list:
                args = []
                cpu_list = []

                # get min and max times for the sync syscall
                context = None # this has to be something useful later on
                abb = state.abbs[state.get_scheduled_task().name]
                min_time = Timings.get_min_time(state.cfg.vp.name[abb], context)

                for cpu_other, graph in metastate.state_graph.items():
                    if cpu != cpu_other:
                        args.append(graph.get_vertices())
                        cpu_list.append(cpu_other)
                
                # compute possible combinations
                if len(args) > 1:
                    mesh = np.array(np.meshgrid(*args)).T.reshape(-1, len(args))
                    print(str(mesh))

                    # TODO: update this for multiple cpus (> 2)

                    for combination in mesh:
                        new_state = metastate.copy()
                        v = new_state.state_graph[cpu].add_vertex()
                        new_state.state_graph[cpu].vp.state[v] = state
                        for i, cpu_other in cpu_list.ennumerate():
                            graph = metastate.state_graph[cpu_other]
                            vertex = graph.vertex(combination[i])
                            next_state = metastate.state_graph[cpu_other].vp.state[vertex]
                            v = new_state.state_graph[cpu_other].add_vertex()
                            new_state.state_graph[cpu_other].vp.state[v] = next_state

                            # execute the syscall
                            self._g.os.interpret(self._lcfg, state.abbs[state.get_scheduled_task().name], new_state, cpu, is_global=True)
                            if new_state not in new_states:
                                new_states.append(new_state)

                else:
                    for cpu_other, graph in metastate.state_graph.items():
                        if cpu != cpu_other:
                            for vertex in args[0]:
                                sync_state = state.copy()
                                next_state = metastate.state_graph[cpu_other].vp.state[vertex].copy()

                                # calculate new timing intervalls for the new states
                                new_times = []
                                for i, intervall_s in enumerate(sync_state.times):
                                    intervall_n = next_state.times[i]

                                    # check if intervall is disjunct
                                    if not (intervall_s[0] > intervall_n[1] or intervall_n[0] > intervall_s[1]):
                                        new_min = max(intervall_s[0], intervall_n[0])
                                        new_max = min(intervall_s[1], intervall_n[1])
                                        new_times.append((new_min, new_max))
                                
                                # skip this combination, if all intervalls are disjunct
                                if len(new_times) == 0:
                                    print("skipped")
                                    continue

                                sync_state.times = new_times.copy()
                                next_state.times = new_times.copy()

                                # construct new metastate
                                new_state = metastate.basic_copy()
                                v = new_state.state_graph[cpu].add_vertex()
                                new_state.state_graph[cpu].vp.state[v] = sync_state
                                v = new_state.state_graph[cpu_other].add_vertex()
                                new_state.state_graph[cpu_other].vp.state[v] = next_state


                                # save the original multistates in the new metastate before executing the syscall
                                # this information is later on used for building the gcfg
                                new_state.entry_states[cpu] = sync_state.copy()
                                new_state.entry_states[cpu_other] = next_state.copy()
                                
                                # execute the syscall
                                self._g.os.interpret(self._lcfg, sync_state.abbs[sync_state.get_scheduled_task().name], new_state, cpu, is_global=True)

                                # calculate new times for both new states
                                sync_task = sync_state.get_scheduled_task()
                                if sync_task is not None:
                                    abb = sync_state.abbs[sync_task.name]
                                    context = None
                                    max_time = Timings.get_max_time(sync_state.cfg.vp.name[abb], context)
                                else:
                                    max_time = math.inf

                                sync_state.add_time(min_time, max_time)
                                
                                next_task = next_state.get_scheduled_task()
                                if next_task is not None:
                                    abb = next_state.abbs[next_task.name]
                                    context = None
                                    max_time = Timings.get_max_time(next_state.cfg.vp.name[abb], context)
                                else:
                                    max_time = math.inf

                                next_state.add_time(min_time, max_time)

                                if new_state not in new_states:    
                                    new_states.append(new_state)

        # remove all timing intervalls from executed metastate
        for cpu, graph in metastate.state_graph.items():
            for v in graph.vertices():
                state = graph.vp.state[v]
                state.merge_times()
                state.times = []

        update_list = []
        # filter out duplicate states by comparing with states in sstg
        for v in self.sstg.vertices():
            sstg_state = self.sstg.vp.state[v]
            for new_state in new_states:
                if new_state.compare_root_states(sstg_state):
                    new_states.remove(new_state)

                    # add timing intervalls to existing state
                    for cpu, graph in sstg_state.state_graph.items():
                        s_state = graph.vp.state[graph.get_vertices()[0]]
                        n_state = new_state.state_graph[cpu].vp.state[new_state.state_graph[cpu].get_vertices()[0]]
                        for intervall in n_state.times:
                            if intervall not in s_state.times:
                                s_state.times.append(intervall)
                    
                    sstg_state.update_timings()
                    if sstg_state.updated < MAX_UPDATES:  
                        sstg_state.updated += 1  
                        update_list.append(sstg_state)
                    
                    # add edge to existing state in sstg
                    if v not in self.sstg.vertex(state_vertex).out_neighbors():
                        e = self.sstg.add_edge(state_vertex, v)
                        self.sstg.ep.state_list[e] = GCFGInfo(new_state.entry_states.copy())

        # run the single core sse on each new state
        res = []
        for new_state in new_states:
            self.run_sse(new_state)

            # check for duplicates
            found = False
            for state in res:
                if state.compare_root_states(new_state):
                    found = True
                    break
            if not found:
                res.append(new_state)   

        new_states = res

        # just for debugging
        for i, new_state in enumerate(new_states):
            for j, new_state_2 in enumerate(new_states):
                if i > j:
                    if new_state == new_state_2:
                        assert(False) 
        
        new_states.extend(update_list)
        return new_states

    def run_sse(self, metastate):
        """Run the single core sse for the given metastate on each cpu."""
        metastate.updated += 1
        for cpu, graph in metastate.state_graph.items():
            global sse_counter
            sse_counter += 1
            stack = []

            for v in graph.vertices():
                stack.append(v)

            while stack:
                vertex = stack.pop(0)
                state = graph.vp.state[vertex]
                for new_state in self.execute_state(state, metastate.sync_states[cpu]):
                    found = False

                    # check for duplicate states
                    for v in graph.vertices():
                        existing_state = graph.vp.state[v]

                        # add edge to existing state if new state is equal
                        if new_state == existing_state:
                            graph.add_edge(vertex, v)
                            found = True

                    # add new state to graph and append it to the stack
                    if not found:
                        new_vertex = graph.add_vertex()
                        graph.vp.state[new_vertex] = new_state
                        graph.add_edge(vertex, new_vertex)
                        stack.append(new_vertex)

        # calculate all timings
        metastate.update_timings()
        
    def execute_state(self, state, sync_list):
        new_states = []
        # self._log.info(f"Executing state: {state}")

        # context used for computing ABB timings, this should be something useful later on
        context = None
        
        task = state.get_scheduled_task()
        if task is not None:
            abb = state.abbs[task.name]
            if abb is not None:

                if self._icfg.vp.type[abb] == ABBType.syscall:
                    assert self._g.os is not None
                    if self._g.os.is_inter_cpu_syscall(self._lcfg, abb, state, state.cpu):
                        # put state into list of syncronization syscalls (inter cpu syscalls)
                        sync_list.append(state)
                    else:
                        new_state = self._g.os.interpret(self._lcfg, abb, state, state.cpu)

                        new_states.append(new_state)
                elif self._icfg.vp.type[abb] == ABBType.call:
                    for n in self._icfg.vertex(abb).out_neighbors():
                        new_state = state.copy()
                        new_state.abbs[task.name] = n

                        # find next call node
                        call_node = None
                        for neighbor in state.callgraphs[task.name].vertex(state.call_nodes[task.name]).out_neighbors():
                            if state.callgraphs[task.name].vp.cfglink[neighbor] == abb:
                                call_node = neighbor
                                break
                        new_state.call_nodes[task.name] = call_node

                        new_states.append(new_state)
                elif (self._icfg.vp.is_exit[abb] and
                    self._icfg.vertex(abb).out_degree() > 0):
                    new_state = state.copy()
                    call = new_state.callgraphs[task.name].vp.cfglink[new_state.call_nodes[task.name]]
                    neighbors = self._lcfg.vertex(call).out_neighbors()
                    new_state.abbs[task.name] = next(neighbors)
                    new_state.call_nodes[task.name] = next(state.call_nodes[task.name].in_neighbors())

                    new_states.append(new_state)
                elif self._icfg.vp.type[abb] == ABBType.computation:
                    for n in self._icfg.vertex(abb).out_neighbors():
                        new_state = state.copy()
                        new_state.abbs[task.name] = n

                        new_states.append(new_state)

        return new_states

    def _schedule(self, states):
        return []
    
    def build_gcfg(self):
        """Adds global control flow edges to the control flow graph."""
        def add_edge(s_abb, t_abb):
            if t_abb not in self._g.cfg.vertex(s_abb).out_neighbors():
                e = self._g.cfg.add_edge(s_abb, t_abb)
                self._g.cfg.ep.type[e] = CFType.gcf

        # add all gcfg edges that are the result of inter cpu syscalls
        for edge in self.sstg.edges():
            entry_states = self.sstg.ep.state_list[edge].entry_states
            t_metastate = self.sstg.vp.state[edge.target()]

            for cpu, graph in t_metastate.state_graph.items():
                # get first graph node (first state)
                t_state = graph.vp.state[graph.get_vertices()[0]]
                
                s_state = entry_states[cpu]

                s_abb = s_state.abbs[s_state.get_scheduled_task().name]
                t_abb = t_state.abbs[t_state.get_scheduled_task().name]
                
                if s_abb != t_abb:
                    add_edge(s_abb, t_abb)
        
        # add all gcfg edges that are the result of syscalls only affecting a single cpu
        for meta_vertex in self.sstg.vertices():
            metastate = self.sstg.vp.state[meta_vertex]

            for cpu, graph in metastate.state_graph.items():
                for edge in graph.edges():
                    s_state = graph.vp.state[edge.source()]
                    t_state = graph.vp.state[edge.target()]

                    s_task = s_state.get_scheduled_task()
                    t_task = t_state.get_scheduled_task()

                    if s_task is not None and t_task is not None:
                        s_abb = s_state.abbs[s_task.name]
                        t_abb = t_state.abbs[t_task.name]

                        if s_abb != t_abb:
                            add_edge(s_abb, t_abb)


    def _finish(self, sstg):
        # output eq time
        print("Total time used for a certain task: " + str(c_debugging))

        # build global control flow graph and print it
        self.build_gcfg()
        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            dot_file = f'{uuid}.GCFG.dot'
            dot_file = self.dump_prefix.get() + dot_file
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'GCFG',
                                           "subgraph": 'abbs'})

        # print the sstg by chaining a printer step
        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            dot_file = f'{uuid}.SIMPLE_SSTG.dot'
            dot_file = self.dump_prefix.get() + dot_file
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'SIMPLE SSTG',
                                           "subgraph": 'sstg_simple',
                                           "graph": sstg})

        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            dot_file = f'{uuid}.Multistates.dot'
            dot_file = self.dump_prefix.get() + dot_file
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'Multistates',
                                           "subgraph": 'multistates',
                                           "graph": sstg})
    
    def print_tasks(self):
        # print all tasks
        log = "Tasks ("
        instances = self._g.instances
        for vertex in instances.vertices():
            task = instances.vp.obj[vertex]
            if isinstance(task, AUTOSAR_Task):
                log += task.name + ", "
        self._log.info(f"{log[:-2]})")

        # print all counters
        log = "Counters ("
        for v in instances.vertices():
            counter = instances.vp.obj[v]
            if isinstance(counter, Counter):
                log += f"{counter}, "
        self._log.info(f"{log[:-2]})")

        # print all alarms
        log = "Alarms ("
        for v in instances.vertices():
            alarm = instances.vp.obj[v]
            if isinstance(alarm, Alarm):
                log += f"{alarm}, "
        self._log.info(f"{log[:-2]})")

    
    def _find_tree_root(self, graph):
        if graph.num_vertices() == 0:
            return None
        node = next(graph.vertices())
        while node.in_degree() != 0:
            node = next(node.in_neighbors())
        return node


class FlatAnalysis(FlowAnalysis):
    """Analysis that run one time over the control flow reachable from the
    entry point.

    This analysis does not respect loops.
    """

    def get_dependencies(self):
        return ["Syscall", "ValueAnalysis", "CallGraph"]

    def _init_analysis(self):
        self._call_graph = self._g.call_graphs[self._entry_func]
        self._cond_func = self._g.call_graphs[self._entry_func].new_vp("bool")
        self._step_data.add(self._entry_func)

        def new_visited_map():
            return self._icfg.new_vp("bool", val=False)
        self._visited = defaultdict(new_visited_map)

    def _get_initial_state(self):
        # find main
        entry_func = self._g.cfg.get_function_by_name(self._entry_func)
        entry_abb = self._g.cfg.get_entry_abb(entry_func)

        entry = State(cfg=self._g.cfg,
                      callgraph=self._g.call_graphs[self._entry_func],
                      next_abbs=[entry_abb])

        self._g.os.init(entry)

        entry.call = self._find_tree_root(self._g.call_graphs[self._entry_func])
        entry.scheduler_on = self._is_chained_analysis(self._entry_func)
        entry.running = self._find_running_instance(self._entry_func)

        return entry

    def _iterate_tasks(self):
        """Return a generator over all tasks in self._g.instances."""
        if self._g.instances is None:
            return
        for v in self._g.instances.vertices():
            os_obj = self._g.instances.vp.obj[v]
            if isinstance(os_obj, Task) and os_obj.is_regular:
                yield os_obj, v

    def _get_task_function(self, task):
        """Return the function which defines a task."""
        assert task.entry_abb is not None, "Not a regular Task."
        entry = self._g.cfg.vertex(task.entry_abb)
        return self._g.cfg.get_function(entry)

    def _find_running_instance(self, entry_func):
        for task, v in self._iterate_tasks():
            func = self._get_task_function(task)
            if self._g.cfg.vp.name[func] == entry_func:
                return v
        return None

    def _is_chained_analysis(self, entry_func):
        return self._find_running_instance(entry_func) is not None

    def _find_tree_root(self, graph):
        if graph.num_vertices() == 0:
            return None
        node = next(graph.vertices())
        while node.in_degree() != 0:
            node = next(node.in_neighbors())
        return node

    def _init_execution(self, state):
        pass

    def _init_fake_state(self, state, abb):
        pass

    def _evaluate_fake_state(self, state, abb):
        pass

    def _handle_call(self, old_state, new_state, abb):
        pass

    def _get_categories(self):
        return SyscallCategory.ALL

    def _get_call_node(self, call_path, abb):
        """Return the call node for the given abb, respecting the call_path."""
        for neighbor in self._call_graph.vertex(call_path).out_neighbors():
            if self._call_graph.vp.cfglink[neighbor] == abb:
                return neighbor
        else:
            abb_name = self._icfg.vp.name[self._icfg.vertex(abb)]
            self._fail(f"Cannot find call path for ABB {abb_name}.")

    def _execute(self, state_vertex):
        state = self.sstg.vp.state[state_vertex]
        new_states = []
        self._init_execution(state)
        for abb in state.next_abbs:
            # don't handle already visted vertices
            if self._visited[state.call][abb]:
                continue
            self._visited[state.call][abb] = True
            self._log.debug(f"Handle state {state}")

            # syscall handling
            if self._icfg.vp.type[abb] == ABBType.syscall:
                fake_state = state.copy()
                self._init_fake_state(fake_state, abb)
                assert self._g.os is not None
                print(getattr(self._g.os, "xQueueGenericCreate"))
                new_state = self._g.os.interpret(self._g.cfg, abb, fake_state,
                                                 categories=self._get_categories())
                self._evaluate_fake_state(new_state, abb)
                new_states.append(new_state)

            # call handling
            elif self._icfg.vp.type[abb] == ABBType.call:
                for n in self._icfg.vertex(abb).out_neighbors():
                    new_state = state.copy()
                    new_state.next_abbs = [n]
                    new_state.call = self._get_call_node(state.call, abb)
                    self._handle_call(state, new_state, abb)
                    new_states.append(new_state)

            # exit handling
            elif (self._icfg.vp.is_exit[abb] and
                  self._icfg.vertex(abb).out_degree() > 0):
                new_state = state.copy()
                call = new_state.callgraph.vp.cfglink[new_state.call]
                neighbors = self._lcfg.vertex(call).out_neighbors()
                new_state.next_abbs = [next(neighbors)]
                new_state.call = next(state.call.in_neighbors())
                new_states.append(new_state)

            # computation block handling
            else:
                for n in self._icfg.vertex(abb).out_neighbors():
                    new_state = state.copy()
                    new_state.next_abbs = [n]
                    new_states.append(new_state)

        return new_states

    def _schedule(self, state):
        # we do simply not care
        return

    def _finish(self, sstg):
        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            dot_file = f'{uuid}.{self._entry_func}.dot'
            dot_file = self.dump_prefix.get() + dot_file
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'Instances',
                                           "subgraph": 'instances'})

class InstanceGraph(FlatAnalysis):
    """Find all application instances."""

    def get_dependencies(self):
        return ["Syscall", "ValueAnalysis", "CallGraph", "FakeEntryPoint"]

    def _init_analysis(self):
        super()._init_analysis()
        self._new_entry_points = set()

    def _dominates(self, abb_x, abb_y):
        """Does abb_x dominate abb_y?"""
        func = self._g.cfg.get_function(abb_x)
        func_other = self._g.cfg.get_function(abb_y)
        if func != func_other:
            return False
        dom_tree = self._create_dom_tree(func)
        while abb_y:
            if abb_x == abb_y:
                return True
            abb_y = dom_tree[abb_y]
        return False

    @functools.lru_cache(maxsize=32)
    def _create_dom_tree(self, func):
        """Create a dominator tree of the local control flow for func."""
        abb = self._g.cfg.get_entry_abb(func)
        comp = label_out_component(self._lcfg, self._lcfg.vertex(abb))
        func_cfg = CFGView(self._lcfg, vfilt=comp)
        dom_tree = dominator_tree(func_cfg, func_cfg.vertex(abb))

        return dom_tree

    @functools.lru_cache(maxsize=32)
    def _find_exit_abbs(self, func):
        return [x for x in func.out_neighbors()
                if self._g.cfg.vp.is_exit[x] or self._g.cfg.vp.is_loop_head[x]]

    def _is_in_condition_or_loop(self, abb):
        """Is abb part of a condition or loop?"""
        func = self._g.cfg.get_function(abb)
        return not all([self._dominates(abb, x)
                        for x in self._find_exit_abbs(func)])

    def _init_fake_state(self, state, abb):
        state.branch = (self._cond_func[state.call] or
                        self._is_in_condition_or_loop(abb))

    def _extract_entry_points(self):
        for task, _ in self._iterate_tasks():
            if (task not in self._new_entry_points):
                func_name = self._g.cfg.vp.name[self._get_task_function(task)]
                if func_name not in self._step_data:
                    # order is different here, the first chained step will
                    # be the last executed one
                    self._step_manager.chain_step({"name": self.get_name(),
                                                   "entry_point": func_name})
                    self._step_manager.chain_step({"name": "ValueAnalysis",
                                                   "entry_point": func_name})
                    self._step_manager.chain_step({"name": "ValueAnalysisCore",
                                                   "entry_point": func_name})
                    self._step_manager.chain_step({"name": "CallGraph",
                                                   "entry_point": func_name})
                    self._step_manager.chain_step({"name": "Syscall",
                                                   "entry_point": func_name})
                    self._step_manager.chain_step({"name": "ICFG",
                                                   "entry_point": func_name})
                    self._step_data.add(func_name)
                self._new_entry_points.add(task)

    def _evaluate_fake_state(self, new_state, abb):
        self._g.instances = new_state.instances
        self._extract_entry_points()

    def _init_execution(self, state):
        if self._g.instances is not None:
            state.instances = self._g.instances

    def _handle_call(self, old_state, new_state, abb):
        new_state.branch = (self._cond_func[old_state.call] or
                            self._is_in_condition_or_loop(abb))
        self._cond_func[new_state.call] = new_state.branch

    def _get_categories(self):
        return SyscallCategory.CREATE

    def _finish(self, sstg):
        super()._finish(sstg)
        self._log.debug(f"_create_dom_tree {self._create_dom_tree.cache_info()}")
        self._log.debug(f"_find_exit_abbs  {self._find_exit_abbs.cache_info()}")


class InteractionAnalysis(FlatAnalysis):
    """Find the flow insensitive interactions between instances."""

    def get_dependencies(self):
        return ["InstanceGraph"]

    def _init_analysis(self):
        super()._init_analysis()
        self._chain_entry_points()

    def _chain_entry_points(self):
        for task, _ in self._iterate_tasks():
            func_name = self._g.cfg.vp.name[self._get_task_function(task)]
            if func_name not in self._step_data:
                self._step_manager.chain_step({"name": self.get_name(),
                                               "entry_point": func_name})
                self._step_data.add(func_name)

    def _get_categories(self):
        return SyscallCategory.COMM

    def _evaluate_fake_state(self, new_state, abb):
        self._g.instances = new_state.instances

    def _init_execution(self, state):
        if self._g.instances is not None:
            state.instances = self._g.instances
