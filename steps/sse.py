"""Container for SSE step."""
import graph_tool
import copy
import logging
import functools

import graph

import pyllco

from native_step import Step
from .option import Option, String, Choice
from .freertos import Task
from .os_util import SyscallCategory
from util import VarianceDict

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


class Flavor:
    def __init__(self, step, g, entry_func):
        self._step = step
        self._entry_func = entry_func
        self._g = g
        self._log = logging.getLogger(f"{step.get_name()}."
                                      f"{self.__class__.__name__}")
        self._log.info(f"Working on {self._entry_func}.")

        self._icfg = graph.CFGView(g.cfg,
                                   efilt=g.cfg.ep.type.fa == graph.CFType.icf)
        self._lcfg = graph.CFGView(g.cfg,
                                   efilt=g.cfg.ep.type.fa == graph.CFType.lcf)

    def system_semantic(self, state):
        new_states = self.execute(state)
        self.schedule(new_states)
        return new_states


class FlowInsensitiveAnalysis(Flavor):
    def __init__(self, step, g, entry_func, side_data):
        super().__init__(step, g, entry_func)
        self.call_map = self._create_call_map(entry_func)
        self.func_branch = self._g.call_graphs[entry_func].new_vp("bool")
        self.side_data = side_data
        self.side_data.add(entry_func)

        def new_visited_map():
            return self._icfg.new_vp("bool", val=False)

        self.visited = defaultdict(new_visited_map)
        self.new_entry_points = set()

    def get_initial_state(self):
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

    def _find_running_instance(self, entry_func):
        if self._g.instances is None:
            return None
        for v in self._g.instances.vertices():
            os_obj = self._g.instances.vp.obj[v]
            if isinstance(os_obj, Task) and os_obj.is_regular:
                entry = self._g.cfg.vertex(os_obj.entry_abb)
                func_name = self._g.cfg.vp.name[
                    self._g.cfg.get_function(entry)
                ]
                if func_name == entry_func:
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

    def _create_call_map(self, entry_func):
        """Create a mapping  'call node -> node index in call_graph'."""
        cg = self._g.call_graphs[entry_func]
        call_map = {}
        for v in cg.vertices():
            call_map[cg.vp.cfglink[v]] = v
        return call_map

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

    def execute(self, state):
        new_states = []
        self._init_execution(state)
        for abb in state.next_abbs:
            # don't handle already visted vertices
            if self.visited[state.call][abb]:
                continue
            self.visited[state.call][abb] = True

            # syscall handling
            if self._icfg.vp.type[abb] == graph.ABBType.syscall:
                fake_state = state.copy()
                self._init_fake_state(fake_state, abb)
                assert self._g.os is not None
                print(getattr(self._g.os, "xQueueGenericCreate"))
                new_state = self._g.os.interpret(self._g.cfg, abb, fake_state,
                                                 categories=self._get_categories())
                self._evaluate_fake_state(new_state, abb)
                new_states.append(new_state)

            # call handling
            elif self._icfg.vp.type[abb] == graph.ABBType.call:
                for n in self._icfg.vertex(abb).out_neighbors():
                    new_state = state.copy()
                    new_state.next_abbs = [n]
                    new_state.call = self.call_map[abb]
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

    def schedule(self, state):
        # we do simply not care
        return

    def finish(self, sstg):
        if self._step.dump.get():
            uuid = self._step._step_manager.get_execution_id()
            dot_file = f'Instances.{uuid}.{self._entry_func}.dot'
            dot_file = self._step.dump_prefix.get() + dot_file
            self._step._step_manager.chain_step({"name": "Printer",
                                                 "dot": dot_file,
                                                 "graph_name": 'Instances',
                                                 "subgraph": 'instances'})


class InstanceGraph(FlowInsensitiveAnalysis):
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
        func_cfg = graph.CFGView(self._lcfg,
                                 vfilt=comp)
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
        state.branch = (self.func_branch[state.call] or
                        self._is_in_condition_or_loop(abb))

    def _extract_entry_points(self):
        for v in self._g.instances.vertices():
            os_obj = self._g.instances.vp.obj[v]
            if isinstance(os_obj, Task):
                if (os_obj not in self.new_entry_points
                    and os_obj.entry_abb is not None):
                    entry = self._g.cfg.vertex(os_obj.entry_abb)
                    func_name = self._g.cfg.vp.name[
                        self._g.cfg.get_function(entry)
                    ]
                    if func_name not in self.side_data:
                        # order is different here, the first chained step will
                        # be the last executed one
                        self._step._step_manager.chain_step(
                            {"name": "SSE",
                             "entry_point": func_name,
                             "flavor": SSE.Flavor.Instances}
                        )
                        self._step._step_manager.chain_step(
                            {"name": "CallGraph",
                             "entry_point": func_name}
                        )
                        self.side_data.add(func_name)
                self.new_entry_points.add(os_obj)

    def _evaluate_fake_state(self, new_state, abb):
        self._g.instances = new_state.instances
        self._extract_entry_points()

    def _init_execution(self, state):
        if self._g.instances is not None:
            state.instances = self._g.instances

    def _handle_call(self, old_state, new_state, abb):
        new_state.branch = (self.func_branch[old_state.call] or
                            self._is_in_condition_or_loop(abb))
        self.func_branch[new_state.call] = new_state.branch

    def _get_categories(self):
        return SyscallCategory.CREATE

    def finish(self, sstg):
        super().finish(sstg)
        self._log.debug(f"_create_dom_tree {self._create_dom_tree.cache_info()}")
        self._log.debug(f"_find_exit_abbs  {self._find_exit_abbs.cache_info()}")


class InteractionAnalysis(FlowInsensitiveAnalysis):
    def _evaluate_fake_state(self, new_state, abb):
        self._g.instances = new_state.instances

    def _init_execution(self, state):
        if self._g.instances is not None:
            state.instances = self._g.instances


# TODO make this a dataclass, when ready
class SSEStepData:
    def __init__(self):
        self.flavor_data = VarianceDict()


class SSE(Step):
    """Apply an OS wide analysis in different depths.

    The extend of the analysis can be switched by the flavor option.
    """

    class Flavor():
        Instances = "InstanceGraph"

    def _fill_options(self):
        self.entry_point = Option(name="entry_point",
                                  help="system entry point",
                                  step_name=self.get_name(),
                                  ty=String())
        self.flavor = Option(name="flavor",
                             help="type of analysis",
                             step_name=self.get_name(),
                             ty=Choice(SSE.Flavor.Instances))
        self.opts += [self.entry_point, self.flavor]

    def get_dependencies(self):
        return ["Syscall", "ValueAnalysis", "CallGraph"]

    def new_vertex(self, sstg, state):
        vertex = sstg.add_vertex()
        sstg.vp.state[vertex] = state
        return vertex

    def run(self, g: graph.Graph):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")

        step_data = self._get_step_data(g, SSEStepData)

        flav = self.flavor.get()
        if flav == SSE.Flavor.Instances:
            flavor = InstanceGraph(
                self,
                g,
                entry_label,
                step_data.flavor_data.get(SSE.Flavor.Instances, set()),
            )
        else:
            self._fail("A flavor must be specified")

        sstg = graph_tool.Graph()
        sstg.vertex_properties["state"] = sstg.new_vp("object")

        state_vertex = self.new_vertex(sstg, flavor.get_initial_state())

        stack = [state_vertex]

        counter = 0
        while stack:
            self._log.debug(f"Stack {counter:3d}: "
                            f"{[sstg.vp.state[v] for v in stack]}")
            state_vertex = stack.pop()
            state = sstg.vp.state[state_vertex]
            for n in flavor.system_semantic(state):
                new_state = self.new_vertex(sstg, n)
                sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)
            counter += 1
        self._log.info(f"Analysis needed {counter} iterations.")

        flavor.finish(sstg)
