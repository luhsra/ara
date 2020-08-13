"""Container for SSE step."""
import graph_tool
import copy
import functools
import numpy as np

import pyllco

from ara.graph import ABBType, Graph, CFGView, CFType
from .step import Step
from .option import Option, String, Choice
from .freertos import Task
from .os_util import SyscallCategory
from ara.util import VarianceDict
from .autosar import Task as AUTOSAR_Task, SyscallInfo
from appl.AUTOSAR.minexample_timing import Timings

from collections import defaultdict
from enum import Enum
from itertools import chain
from graph_tool.topology import dominator_tree, label_out_component



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

        state_vertex = self.new_vertex(self.sstg, self._get_initial_state())

        stack = [state_vertex]

        counter = 0
        while stack:
            self._log.debug(f"Stack {counter:3d}: "
                            f"{[self.sstg.vp.state[v] for v in stack]}")
            state_vertex = stack.pop()
            # state = self.sstg.vp.state[state_vertex]
            for n in self._system_semantic(state_vertex):
                new_state = self.new_vertex(self.sstg, n)
                e = self.sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)
            counter += 1
        self._log.info(f"Analysis needed {counter} iterations.")

        self._finish(self.sstg)

class MetaState:
    def __init__(self, cfg=None, instances=None):
        self.cfg = cfg
        self.instances = instances
        self.state_graph = {} # graph of Multistates for each cpu
                              # key: cpu id, value: graph of Multistates
        self.sync_states = {} # list of MultiStates for each cpu, which handle 
                              # a syscall that affects other cpus
                              # key: cpu id, value: list of MultiStates

    def __repr__(self):
        ret = "["

        for cpu, graph in self.state_graph.items():
            ret += f"{graph}, "
        return ret[:-2] + "]"
    
    def basic_copy(self):
        copy = MetaState(self.cfg, self.instances)

        for cpu in self.state_graph:
            copy.state_graph[cpu] = graph_tool.Graph()
            copy.sync_states[cpu] = []
            copy.state_graph[cpu].vertex_properties["state"] = copy.state_graph[cpu].new_vp("object")

        return copy

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
        # self.gcfg_multi_ret = {} # indication for gcfg building wether the global control flow 
                                 # returns to a single abb or multiple ones
                                 # key: task name, value: bool
        self.cpu = cpu
        self.min_time = 0
        self.max_time = 0
        self.times = [] # list of time intervalls this state is valid in
        
    def get_scheduled_task(self):
        if len(self.activated_tasks) >= 1:
            return self.activated_tasks[0]
        else: 
            return None

    def add_time(self, min_time, max_time):
        self.max_time += max_time        
        self.min_time += min_time

        # add new time intervall to list and merge it if necessary
        self.times.append((self.min_time, self.max_time))
        if len(self.times) > 1:
            self.times.sort(key=lambda intervall: intervall[0])

            def merge(time_1, time_2):
                if time_1[1] < time_2[0]:
                    return False, None
                if time_1[1] < time_2[1]:
                    return True, (time_1[0], time_2[1])
                else:
                    return True, (time_1[0], time_1[1])

            while True:
                new_times = self.times.copy()
                for i, time in enumerate(new_times):
                    if i != len(new_times) - 1:
                        merged, intervall = merge(new_times[i], new_times[i + 1])
                        if merged:
                            self.times[i] = intervall
                            self.times.pop(i + 1)
                            break
                if new_times == self.times:
                    break

    def __repr__(self):
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
        ret = ret[:-2] + "] " + str(self.times)
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
        scopy.times = []
        # scopy.gcfg_multi_ret = self.gcfg_multi_ret.copy()

        return scopy

class MultiSSE(FlowAnalysis):
    """Run the MultiCore SSE."""
    # TODOs:
    # TODO: add edge information to gcfg edges if a call returns to a task
    #       to determine for which task/abb this edge is viable
    #       (necessary when a function is shared)
    # TODO: somehow get the timing information

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

        # run single core sse for each cpu
        self.run_sse(metastate)

        return metastate

    def _execute(self, state_vertex):
        metastate = self.sstg.vp.state[state_vertex]
        self._log.info(f"Executing Metastate: {metastate}")
        new_states = []

        for cpu, sync_list in metastate.sync_states.items():
            for state in sync_list:
                args = []
                cpu_list = []

                # get min and max times for the sync syscall
                context = None # this has to be something useful later on
                abb = state.abbs[state.get_scheduled_task().name]
                min_time = Timings.get_min_time(state.cfg.vp.name[abb], context)
                max_time = Timings.get_max_time(state.cfg.vp.name[abb], context)

                for cpu_other, graph in metastate.state_graph.items():
                    if cpu != cpu_other:
                        args.append(graph.get_vertices())
                        cpu_list.append(cpu_other)
                
                # compute possible combinations
                if len(args) > 1:
                    mesh = np.array(np.meshgrid(*args)).T.reshape(-1, len(args))
                    print(str(mesh))

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
                                next_state = metastate.state_graph[cpu_other].vp.state[vertex]

                                # skip this state if sync state times are higher than max or lower than min
                                if next_state.max_time is not None and sync_state.min_time > next_state.max_time:
                                    print("skipped")
                                    continue
                                if sync_state.max_time is not None and sync_state.max_time < next_state.min_time:
                                    print("skipped")
                                    continue

                                next_state = next_state.copy()
                                
                                new_state = metastate.basic_copy()
                                v = new_state.state_graph[cpu].add_vertex()
                                new_state.state_graph[cpu].vp.state[v] = sync_state
                                v = new_state.state_graph[cpu_other].add_vertex()
                                new_state.state_graph[cpu_other].vp.state[v] = next_state
                                
                                # execute the syscall
                                self._g.os.interpret(self._lcfg, sync_state.abbs[sync_state.get_scheduled_task().name], new_state, cpu, is_global=True)

                                # set new min and max times for both new states
                                new_min = max(sync_state.min_time, next_state.min_time)
                                new_max = min(sync_state.max_time, next_state.max_time)
                                next_state.min_time = new_min
                                next_state.max_time = new_max
                                sync_state.min_time = new_min
                                sync_state.max_time = new_max
                                sync_state.add_time(min_time, max_time)
                                next_state.add_time(min_time, max_time)

                                if new_state not in new_states:    
                                    new_states.append(new_state)
                    
        # run the single core sse on each new state
        res = []
        for new_state in new_states:
            self.run_sse(new_state)

            # check for duplicates
            found = False
            for state in res:
                if state == new_state:
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
                        
        # filter out duplicate states by comparing with states in sstg
        for v in self.sstg.vertices():
            sstg_state = self.sstg.vp.state[v]
            for new_state in new_states:
                if new_state == sstg_state:
                    new_states.remove(new_state)
                    
                    # add edge to existing state in sstg
                    e = self.sstg.add_edge(state_vertex, v)

        return new_states

    def run_sse(self, metastate):
        """Run the single core sse for the given metastate on each cpu."""
        for cpu, graph in metastate.state_graph.items():
            stack = []

            for v in graph.vertices():
                stack.append(v)

            while stack:
                vertex = stack.pop()
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
        
    def execute_state(self, state, sync_list):
        new_states = []
        # self._log.info(f"Executing state: {state}")

        # context used for computing ABB timings, this should be something useful later on
        context = None
        
        task = state.get_scheduled_task()
        if task is not None:
            abb = state.abbs[task.name]
            if abb is not None:
                # get min and max times for this abb
                min_time = Timings.get_min_time(state.cfg.vp.name[abb], context)
                max_time = Timings.get_max_time(state.cfg.vp.name[abb], context)

                if self._icfg.vp.type[abb] == ABBType.syscall:
                    assert self._g.os is not None
                    if self._g.os.is_inter_cpu_syscall(self._lcfg, abb, state, state.cpu):
                        # put state into list of syncronization syscalls (inter cpu syscalls)
                        sync_list.append(state)
                    else:
                        new_state = self._g.os.interpret(self._lcfg, abb, state, state.cpu)
                        
                        # set new min and max times
                        new_state.add_time(min_time, max_time)

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

                        # set new min and max times
                        new_state.add_time(min_time, max_time)

                        new_states.append(new_state)
                elif (self._icfg.vp.is_exit[abb] and
                    self._icfg.vertex(abb).out_degree() > 0):
                    new_state = state.copy()
                    call = new_state.callgraphs[task.name].vp.cfglink[new_state.call_nodes[task.name]]
                    neighbors = self._lcfg.vertex(call).out_neighbors()
                    new_state.abbs[task.name] = next(neighbors)
                    new_state.call_nodes[task.name] = next(state.call_nodes[task.name].in_neighbors())

                    # set new min and max times
                    new_state.add_time(min_time, max_time)
                    
                    new_states.append(new_state)
                elif self._icfg.vp.type[abb] == ABBType.computation:
                    for n in self._icfg.vertex(abb).out_neighbors():
                        new_state = state.copy()
                        new_state.abbs[task.name] = n

                        # set new min and max times
                        new_state.add_time(min_time, max_time)

                        new_states.append(new_state)

        return new_states

    def _schedule(self, states):
        return []
    
    def build_gcfg(self):
        """Adds global control flow edges to the control flow graph."""
        for edge in self.sstg.edges():
            s_state = self.sstg.vp.state[edge.source()]
            t_state = self.sstg.vp.state[edge.target()]
            for cpu in s_state.activated_tasks:
                s_task = s_state.get_scheduled_task(cpu)
                t_task = t_state.get_scheduled_task(cpu)
                if s_task is not None and t_task is not None and s_task.name != t_task.name:

                    def add_edge(s_abb, t_abb):
                        if t_abb not in self._g.cfg.vertex(s_abb).out_neighbors():
                            e = self._g.cfg.add_edge(s_abb, t_abb)
                            self._g.cfg.ep.type[e] = CFType.gcf

                    # we assume that the target abb is the first element in the list
                    # since the list is not sorted
                    t_abb = t_state.abbs[t_task.name][0]

                    # getting info about last syscall
                    info = self.sstg.ep.syscall[edge]

                    # if last syscall was TerminateTask only one edge is added
                    # unless the multi ret flag was set in the task
                    if info.name == "TerminateTask":
                        if info.cpu == cpu:
                            s_abb = info.abb
                            if info.multi_ret:
                                for t_abb in t_state.abbs[t_task.name]:
                                    add_edge(s_abb, t_abb)
                            else:
                                add_edge(s_abb, t_abb)

                    # if last syscall was ActivateTask we have to see if the activated task
                    # is on the same cpu as the syscall, then we only need to add one edge
                    elif info.name == "ActivateTask":
                        if info.cpu == cpu:
                            s_abb = info.abb
                            add_edge(s_abb, t_abb)
                        else:
                            # add edge from each source abb to first target abb
                            for abb in s_state.abbs[s_task.name]:
                                add_edge(abb, t_abb)
                    else:
                        # default: add edge from each source abb to first target abb
                        for abb in s_state.abbs[s_task.name]:
                            # TODO: find root node of lcfg from this abb and check if entry node of one of the tasks
                            #       if not add label to edge
                            add_edge(abb, t_abb)


    def _finish(self, sstg):
        # build global control flow graph and print it
        # self.build_gcfg()
        # if self.dump.get():
        #     uuid = self._step_manager.get_execution_id()
        #     dot_file = f'{uuid}.GCFG.dot'
        #     dot_file = self.dump_prefix.get() + dot_file
        #     self._step_manager.chain_step({"name": "Printer",
        #                                    "dot": dot_file,
        #                                    "graph_name": 'GCFG',
        #                                    "subgraph": 'abbs'})

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
        log = "Tasks ("
        instances = self._g.instances
        for vertex in instances.vertices():
            task = instances.vp.obj[vertex]
            log += task.name + ", "
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
