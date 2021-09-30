"""Container for SSE."""
from .step import Step
from .option import Option, String
from .cfg_traversal import Visitor, run_sse

import graph_tool


class SSE(Step):
    """Run a single core SSE."""

    entry_point = Option(name="entry_point", help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        if self._graph.os is None:
            return ["SysFuncts"]
        deps = self._graph.os.get_special_steps()
        return deps

    def run(self):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")
        self._log.info(f"Analyzing entry point: '{entry_label}'")

        sstg = graph_tool.Graph()
        sstg.vertex_properties["state"] = sstg.new_vp("object")
        sstg.edge_properties["syscall"] = sstg.new_ep("object")

        os_state = self._graph.os.get_initial_state(
            self._graph.cfg, self._graph.instances
        )

        state_map = {}

        assert len(os_state.cpus) == 1, "SSE does not support more than one CPU."

        class SSEVisitor(Visitor):
            PREVENT_MULTIPLE_VISITS = True

            @staticmethod
            def get_initial_state():
                return os_state

            @staticmethod
            def init_execution(_):
                return

            @staticmethod
            def is_bad_call_target(_):
                return False

            @staticmethod
            def schedule(new_states):
                return self._graph.os.schedule(new_states, [0])

            @staticmethod
            def add_state(new_state):
                s = sstg.add_vertex()
                sstg.vp.state[s] = new_state
                state_map[new_state] = s

            @staticmethod
            def add_transition(source, target):
                sstg.add_edge(state_map[source], state_map[target])

            @staticmethod
            def next_step(counter):
                pass

        run_sse(
            self._graph,
            self._graph.os,
            visitor=SSEVisitor(),
            logger=self._log,
        )
