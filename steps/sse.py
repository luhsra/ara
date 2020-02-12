"""Container for SSE step."""
import graph_tool
import logging
import functools

import graph

import pyllco

from native_step import Step
from .option import Option, String, Choice
from .freertos import Task

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


class AbstractOS:
    def __init__(self, step, g):
        self.step = step
        self.g = g
        self._log = logging.getLogger(f"{step.get_name()}."
                                      f"{self.__class__.__name__}")

        self.icfg = graph.CFGView(g.cfg,
                                  efilt=g.cfg.ep.type.fa == graph.CFType.icf)
        self.lcfg = graph.CFGView(g.cfg,
                                  efilt=g.cfg.ep.type.fa == graph.CFType.lcf)

    def system_semantic(self, state):
        new_states = self.execute(state)
        self.schedule(new_states)
        return new_states


class InstanceGraph(AbstractOS):
    def __init__(self, step, g, state, entry_func, step_manager,
                 dump, dump_prefix):
        super().__init__(step, g)
        self.g.os.init(state)
        self.call_map = self._create_call_map(entry_func)
        self.func_branch = self.g.call_graphs[entry_func].new_vp("bool")

        self._step_manager = step_manager
        if dump:
            self.dump_prefix = dump_prefix
        else:
            self.dump_prefix = None

        def new_visited_map():
            return self.icfg.new_vp("bool", val=False)

        self.visited = defaultdict(new_visited_map)
        if self.g.instances is None:
            self.instances = state.instances
        else:
            self.instances = self.g.instances
        self.new_entry_points = set()

        state.call = self._find_tree_root(self.g.call_graphs[entry_func])

    def _find_tree_root(self, graph):
        if graph.num_vertices() == 0:
            return None
        node = next(graph.vertices())
        while node.in_degree() != 0:
            node = next(node.in_neighbors())
        return node

    def _create_call_map(self, entry_func):
        """Create a mapping  'call node -> node index in call_graph'."""
        cg = self.g.call_graphs[entry_func]
        call_map = {}
        for v in cg.vertices():
            call_map[cg.vp.cfglink[v]] = v
        return call_map

    @functools.lru_cache(maxsize=32)
    def _create_dom_tree(self, func):
        """Create a dominator tree of the local control flow for func."""
        abb = self.g.cfg.get_entry_abb(func)
        comp = label_out_component(self.lcfg, self.lcfg.vertex(abb))
        func_cfg = graph.CFGView(self.lcfg,
                                 vfilt=comp)
        dom_tree = dominator_tree(func_cfg, func_cfg.vertex(abb))

        return dom_tree

    def _dominates(self, abb_x, abb_y):
        """Does abb_x dominate abb_y?"""
        func = self.g.cfg.get_function(abb_x)
        func_other = self.g.cfg.get_function(abb_y)
        if func != func_other:
            return False
        dom_tree = self._create_dom_tree(func)
        while abb_y:
            if abb_x == abb_y:
                return True
            abb_y = dom_tree[abb_y]
        print("No")
        return False

    @functools.lru_cache(maxsize=32)
    def _find_exit_abbs(self, func):
        return [x for x in func.out_neighbors()
                if self.g.cfg.vp.is_exit[x] or self.g.cfg.vp.is_loop_head[x]]

    def _is_in_condition_or_loop(self, abb):
        """Is abb part of a condition or loop?"""
        func = self.g.cfg.get_function(abb)
        return not all([self._dominates(abb, x)
                        for x in self._find_exit_abbs(func)])

    def _extract_entry_points(self):
        for v in self.instances.vertices():
            os_obj = self.instances.vp.obj[v]
            if isinstance(os_obj, Task):
                if (os_obj not in self.new_entry_points
                    and os_obj.entry_abb is not None):
                    entry = self.g.cfg.vertex(os_obj.entry_abb)
                    func_name = self.g.cfg.vp.name[
                        self.g.cfg.get_function(entry)
                    ]
                    # order is different here, the first chained step will be
                    # the last executed one
                    self._step_manager.chain_step({"name": "SSE",
                                                   "entry_point": func_name,
                                                   "flavor": SSE.Flavor.Instances})
                    self._step_manager.chain_step({"name": "CallGraph",
                                                   "entry_point": func_name})
                self.new_entry_points.add(os_obj)

    def execute(self, state):
        new_states = []
        state.instances = self.instances
        for abb in state.next_abbs:
            if self.visited[state.call][abb]:
                continue
            self.visited[state.call][abb] = True

            if self.icfg.vp.type[abb] == graph.ABBType.syscall:
                fake_state = state.copy()
                fake_state.branch = (self.func_branch[state.call] or
                                     self._is_in_condition_or_loop(abb))
                assert self.g.os is not None
                new_state = self.g.os.interpret(self.g.cfg, abb, fake_state)
                self.instances = new_state.instances
                self._extract_entry_points()
                new_states.append(new_state)

            elif self.icfg.vp.type[abb] == graph.ABBType.call:
                for n in self.icfg.vertex(abb).out_neighbors():
                    new_state = state.copy()
                    new_state.next_abbs = [n]
                    print(state.call)
                    new_state.branch = (self.func_branch[state.call] or
                                        self._is_in_condition_or_loop(abb))
                    new_state.call = self.call_map[abb]
                    self.func_branch[new_state.call] = new_state.branch

                    new_states.append(new_state)

            elif (self.icfg.vp.is_exit[abb] and
                  self.icfg.vertex(abb).out_degree() > 0):
                new_state = state.copy()
                call = new_state.callgraph.vp.cfglink[new_state.call]
                neighbors = self.lcfg.vertex(call).out_neighbors()
                new_state.next_abbs = [next(neighbors)]
                print(self.icfg.vp.name[abb])
                new_state.call = next(state.call.in_neighbors())
                new_states.append(new_state)

            else:
                for n in self.icfg.vertex(abb).out_neighbors():
                    new_state = state.copy()
                    new_state.next_abbs = [n]

                    new_states.append(new_state)

        return new_states

    def schedule(self, state):
        # we do simply not care
        return

    def finish(self, sstg):
        self._log.debug(f"_create_dom_tree {self._create_dom_tree.cache_info()}")
        self._log.debug(f"_find_exit_abbs  {self._find_exit_abbs.cache_info()}")
        self.g.instances = self.instances
        if self.dump_prefix:
            # TODO quick and dirty, implement in printer with UUID
            inst = self.instances.copy()
            del inst.vp["obj"]
            import time
            inst.save(f"State.{time.time()}.dot")


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

        # find main
        entry_func = g.cfg.get_function_by_name(entry_label)
        entry_abb = g.cfg.get_entry_abb(entry_func)

        entry = State(cfg=g.cfg,
                      callgraph=g.call_graphs[entry_label],
                      next_abbs=[entry_abb])
        flav = self.flavor.get()
        if flav == SSE.Flavor.Instances:
            flavor = InstanceGraph(
                self, g,
                entry, entry_label,
                self._step_manager, self.dump.get(),
                self.dump_prefix.get()
            )
        else:
            self._fail("A flavor must be specified")

        sstg = graph_tool.Graph()
        sstg.vertex_properties["state"] = sstg.new_vp("object")

        state_vertex = self.new_vertex(sstg, entry)

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
