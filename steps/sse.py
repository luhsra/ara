"""Container for SSE step."""
import graph_tool

import graph

import pyllco

from native_step import Step
from .option import Option, String, Choice
from .freertos import Task

from itertools import chain
from collections import defaultdict

from enum import Enum


class State:
    def __init__(self, cfg=None, callgraph=None, next_abbs=None):
        self.cfg = cfg
        self.callgraph = callgraph
        if not next_abbs:
            next_abbs = []
        self.next_abbs = next_abbs

        self.instances = graph_tool.Graph()
        self.call = None

    def __repr__(self):
        ret = 'State('
        abbs = [self.cfg.vp.name[abb] for abb in self.next_abbs]
        ret += ', '.join(abbs)
        return ret + ')'

    def copy(self):
        scopy = State()
        scopy.cfg = self.cfg
        scopy.next_abbs = self.next_abbs
        scopy.instances = self.instances.copy()
        scopy.callgraph = self.callgraph
        scopy.call = self.call
        return scopy


class AbstractOS:
    def __init__(self, g):
        self.g = g

        self.icfg = graph.CFGView(g.cfg,
                                 efilt=g.cfg.ep.type.fa == graph.CFType.icf)
        self.lcfg = graph.CFGView(g.cfg,
                                  efilt=g.cfg.ep.type.fa == graph.CFType.lcf)

    def system_semantic(self, state):
        new_states = self.execute(state)
        self.schedule(new_states)
        return new_states


class InstanceGraph(AbstractOS):
    def __init__(self, g, state, entry_func, step_manager):
        super().__init__(g)
        self.g.os.init(state)
        self.call_map = self._create_call_map(entry_func)
        self._step_manager = step_manager

        def new_visited_map():
            return self.icfg.new_vp("bool", val=False)

        self.visited = defaultdict(new_visited_map)
        self.instances = state.instances
        self.new_entry_points = set()

    def states_are_equal(state1, state2):
        equal = bool(state1.next_abbs & state2.next_abbs)
        return equal

    def _extract_entry_points(self):
        for v in self.instances.vertices():
            os_obj = self.instances.vp.obj[v]
            if isinstance(os_obj, Task):
                if os_obj not in self.new_entry_points:
                    entry = self.g.cfg.vertex(os_obj.entry_abb)
                    func_name = self.g.cfg.vp.name[
                        self.g.cfg.get_function(entry)
                    ]
                    self._step_manager.chain_step({"name": "SSE",
                                                   "entry_point": func_name,
                                                   "flavor": SSE.Flavor.Instances})
                    self._step_manager.chain_step({"name": "CallGraph",
                                                   "entry_point": func_name})
                self.new_entry_points.add(os_obj)

    def _create_call_map(self, entry_func):
        cg = self.g.call_graphs[entry_func]
        call_map = {}
        for v in cg.vertices():
            call_map[cg.vp.cfglink[v]] = v
        return call_map

    def execute(self, state):
        new_states = []
        state.instances = self.instances
        for abb in state.next_abbs:
            if self.visited[state.call][abb]:
                continue
            self.visited[state.call][abb] = True
            if self.icfg.vp.type[abb] == graph.ABBType.syscall:
                assert self.g.os is not None
                new_state = self.g.os.interpret(self.g.cfg, abb, state)
                self.instances = new_state.instances
                self._extract_entry_points()
                new_states.append(new_state)
            elif self.icfg.vp.type[abb] == graph.ABBType.call:
                for n in self.icfg.vertex(abb).out_neighbors():
                    new_state = state.copy()
                    new_state.next_abbs = [n]
                    new_state.call = self.call_map[abb]

                    new_states.append(new_state)
            elif self.icfg.vp.is_exit[abb]:
                new_state = state.copy()
                call = new_state.callgraph.vp.cfglink[new_state.call]
                neighbors = self.lcfg.vertex(call).out_neighbors()
                new_state.next_abbs = [next(neighbors)]
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


class SSE(Step):
    """Template for a new Python step."""

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
            flavor = InstanceGraph(g, entry, entry_label, self._step_manager)
        else:
            self._fail("A flavor must be specified")

        sstg = graph_tool.Graph()
        sstg.vertex_properties["state"] = sstg.new_vp("object")

        state_vertex = self.new_vertex(sstg, entry)

        stack = [state_vertex]

        counter = 0
        while stack:
            self._log.debug(f"Stack: {[sstg.vp.state[v] for v in stack]}")
            state_vertex = stack.pop()
            state = sstg.vp.state[state_vertex]
            for n in flavor.system_semantic(state):
                inst = n.instances.copy()
                del inst.vp["obj"]
                inst.save(f"State.{counter}.dot", fmt='dot')
                counter += 1
                new_state = self.new_vertex(sstg, n)
                sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)
