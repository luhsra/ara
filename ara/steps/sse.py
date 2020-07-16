"""Container for SSE step."""
import graph_tool
import copy
import functools

import pyllco

from ara.graph import ABBType, Graph, CFGView, CFType
from .step import Step
from .option import Option, String, Choice
from .freertos import Task
from .os_util import SyscallCategory
from ara.util import VarianceDict
from .autosar import Task as AUTOSAR_Task

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
                self.sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)
            counter += 1
        self._log.info(f"Analysis needed {counter} iterations.")

        self._finish(self.sstg)

class MultiState:
    def __init__(self, cfg=None, instances=None):
        self.cfg = cfg
        self.instances = instances
        self.entry_abbs = {} # entry abbs for each task; key: task name, value: entry abb node
        self.call_nodes = {} # call node of each task (used for handling calls)
                             # key: task name, value: ABB node (call node)
        self.callgraphs = {} # callgraphs for each task; key: task name, value: callgraph
        self.abbs = {} # active ABBs per task; key: task name, value: list of ABB nodes
        self.activated_tasks = {} # actived Tasks per cpu; key: cpu_id, value: List of Task nodes
    
    def get_scheduled_task(self, cpu):
        task_list = self.activated_tasks[cpu]
        if len(task_list) >= 1:
            return task_list[0]
        else: 
            return None
    
    def explore(self, cfg):
        """Explore the state to contain all abbs that can be reached from 
        the inital abb stopping at syscall abbs."""
        for cpu in self.activated_tasks:
            task = self.get_scheduled_task(cpu)
            if task is not None:
                abb_list = self.abbs[task.name]

                # only explore new states (when their list only contains one abb)
                if (len(abb_list) == 1):
                    stack = [abb_list[0]]

                    # explore neighbors until no new none syscall abb is found
                    while stack:
                        abb = stack.pop()

                        # append neighbors to abb list and to stack if not a syscall
                        for n in cfg.vertex(abb).out_neighbors():
                            if n not in abb_list:
                                abb_list.append(n)
                            if not cfg.vp.type[n] == ABBType.syscall:
                                stack.append(n)

    def __repr__(self):
        ret = ""
        for cpu in self.activated_tasks:
            task = self.get_scheduled_task(cpu)
            if task is not None:
                ret += "["
                for abb in self.abbs[task.name]:
                    ret += self.cfg.vp.name[abb] + ", "
                ret = ret[:-2] 
                ret += "], "
            else: 
                ret += "None, "
        return ret[:-2]

    def __eq__(self, other):
        class_eq = self.__class__ == other.__class__
        abbs_eq = self.abbs == other.abbs
        activated_task_eq = self.activated_tasks == other.activated_tasks
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

        # copy lists of activated tasks
        for k in scopy.activated_tasks:
            scopy.activated_tasks[k] = self.activated_tasks[k].copy()

        # copy list of abb nodes in abbs dict
        for k in scopy.abbs:
            scopy.abbs[k] = self.abbs[k].copy()

        return scopy

class MultiSSE(FlowAnalysis):
    """Run the MultiCore SSE."""
    def get_dependencies(self):
        return ["SysFuncts"]

    def _init_analysis(self):
        pass

    def _get_initial_state(self):
        self.print_tasks()
        state = MultiState(cfg=self._g.cfg,
                           instances=self._g.instances) 

        # building initial state
        # TODO: get rid of the hardcoded function name
        func_name_start = "AUTOSAR_TASK_FUNC_"
        for v in state.instances.vertices():
            task = state.instances.vp.obj[v]

            if isinstance(task, AUTOSAR_Task):
                # set entry abb for each task
                func_name = func_name_start + task.name
                entry_func = self._g.cfg.get_function_by_name(func_name)
                entry_abb = self._g.cfg.get_entry_abb(entry_func)
                state.entry_abbs[task.name] = entry_abb
                state.abbs[task.name] = [entry_abb]

                # set callgraph and entry call node for each task
                state.callgraphs[task.name] = self._g.call_graphs[func_name]
                state.call_nodes[task.name] = self._find_tree_root(self._g.call_graphs[func_name])
                
                # set list of activated tasks for each cpu
                if task.autostart: 
                    if task.cpu_id not in state.activated_tasks:
                        state.activated_tasks[task.cpu_id] = []
                    state.activated_tasks[task.cpu_id].append(task)

        state.explore(self._icfg)
        return state

    def _execute(self, state_vertex):
        state = self.sstg.vp.state[state_vertex]
        self._log.info(f"Executing State: {state}")
        new_states = []
        
        for cpu in state.activated_tasks:
            task = state.get_scheduled_task(cpu)
            if task is not None:
                for abb in state.abbs[task.name]:
                    if abb is not None:
                        # syscall handling
                        if self._icfg.vp.type[abb] == ABBType.syscall:
                            assert self._g.os is not None
                            new_state = self._g.os.interpret(self._lcfg, abb, state, cpu)
                            new_state.explore(self._icfg)
                            new_states.append(new_state)
                        
        # filter out duplicate states by comparing with states in sstg
        for v in self.sstg.vertices():
            sstg_state = self.sstg.vp.state[v]
            for new_state in new_states:
                if new_state == sstg_state:
                    new_states.remove(new_state)
                    self.sstg.add_edge(state_vertex, v)

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
                    # add edge from each source abb to first target abb
                    # we assume that the target abb is the first element in the list
                    # since the list is not sorted
                    t_abb = t_state.abbs[t_task.name][0]
                    for abb in s_state.abbs[s_task.name]:
                        if t_abb not in self._g.cfg.vertex(abb).out_neighbors():
                            e = self._g.cfg.add_edge(abb, t_abb)
                            self._g.cfg.ep.type[e] = CFType.gcf


    def _finish(self, sstg):
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
            dot_file = f'{uuid}.SSTG.dot'
            dot_file = self.dump_prefix.get() + dot_file
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'SSTG',
                                           "subgraph": 'sstg',
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
