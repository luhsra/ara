"""Container for SSE step."""
import graph_tool

import graph

import pyllco

from native_step import Step
from .option import Option, String

from itertools import chain


class State:
    def __init__(self, cfg, *args):
        self.cfg = cfg
        self.next_abbs = []
        if args:
            self.next_abbs = list(args)
        self.instances = graph_tool.Graph()

    def __repr__(self):
        ret = 'State('
        abbs = [self.cfg.vp.name[abb] for abb in self.next_abbs]
        ret += ', '.join(abbs)
        return ret + ')'

    def copy(self):
        scopy = State(self.cfg, *self.next_abbs)
        scopy.instances = self.instances.copy()
        return scopy


class AbstractOS:
    def __init__(self, g):
        self.g = g

        def is_icf(e):
            return g.cfg.ep.type[e] == graph.CFType.icf
        self.cfg = graph_tool.GraphView(g.cfg, efilt=is_icf)

    def system_semantic(self, state):
        new_states = self.execute(state)
        self.schedule(new_states)
        return new_states


class InstanceGraph(AbstractOS):
    def __init__(self, g, state):
        super().__init__(g)
        self.g.os.init(state)
        self.visited = self.cfg.new_vp("bool", val=False)

    def execute(self, state):
        next_states = {'normal': [], 'syscall': []}
        fake_state = state.copy()
        processed = False

        next_abbs = set()
        for abb in state.next_abbs:
            if self.visited[abb]:
                continue
            self.visited[abb] = True
            processed = True

            if self.cfg.vp.type[abb] == graph.ABBType.syscall:
                assert self.g.os is not None
                state = self.g.os.interpret(self.g.cfg, abb, fake_state)
                if (state.instances.num_vertices() >= fake_state.instances.num_vertices() and
                    state.instances.num_edges() >= fake_state.instances.num_edges()):
                    fake_state.instances = state.instances
                next_abbs |= set(state.next_abbs)
            else:
                # don't touch the state, just follow the control flow
                next_abbs |= set(self.cfg.vertex(abb).out_neighbors())

        if processed:
            fake_state.next_abbs = list(next_abbs)
            return [fake_state]
        return []

    def schedule(self, state):
        # we do simply not care
        return


class SSE(Step):
    """Template for a new Python step."""

    def _fill_options(self):
        self.entry_point = Option(name="entrypoint",
                                  help="system entry point",
                                  step_name=self.get_name(),
                                  ty=String())
        self.opts.append(self.entry_point)

    def get_dependencies(self):
        return ["Syscall", "ValueAnalysis"]

    def new_vertex(self, sstg, state):
        vertex = sstg.add_vertex()
        sstg.vp.state[vertex] = state
        return vertex

    def run(self, g: graph.Graph):
        entry_label = self.entry_point.get()
        assert entry_label is not None

        # find main
        entry_func = g.cfg.get_function_by_name(entry_label)
        entry_abb = g.cfg.get_entry_abb(entry_func)
        print(entry_abb)

        entry = State(g.cfg, entry_abb)
        flavor = InstanceGraph(g, entry)

        sstg = graph_tool.Graph()
        sstg.vertex_properties["state"] = sstg.new_vp("object")

        state_vertex = self.new_vertex(sstg, entry)

        stack = [state_vertex]

        counter = 0
        while stack:
            state_vertex = stack.pop(0)
            state = sstg.vp.state[state_vertex]
            self._log.debug(f"executing state {state}")
            for n in flavor.system_semantic(state):
                n.instances.save(f"State.{counter}.dot", fmt='dot')
                counter += 1
                new_state = self.new_vertex(sstg, n)
                sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)
