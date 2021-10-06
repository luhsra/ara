"""Container for SSE."""
from .step import Step
from .option import Option, String, Bool
from .cfg_traversal import Visitor, run_sse

import graph_tool
import html
import os
import pydot


class SSE(Step):
    """Run a single core SSE."""

    entry_point = Option(name="entry_point", help="system entry point",
                         ty=String())

    detailed_dump = Option(name="detailed_dump", help="Output the state graph every iteration (WARNING: produces _a lot of_ files).",
                           ty=Bool(),
                           default_value=False)

    def get_single_dependencies(self):
        if self._graph.os is None:
            return ["SysFuncts"]
        deps = self._graph.os.get_special_steps()
        return deps

    def _state_as_dot(self, sstg, state_vert):
        attrs = {"fontsize": 14}
        size = 12
        cfg = self._graph.cfg

        obj = sstg.vp.state[state_vert]
        label = f"State {obj.id}"
        cpu = obj.cpus[0]
        if cpu.control_instance:
            instance = obj.instances.vp.label[obj.instances.vertex(cpu.control_instance)]
        else:
            instance = "Idle"
        if cpu.abb:
            syscall = cfg.get_syscall_name(cpu.abb)
            if syscall != "":
                syscall = f" ({syscall})"
            abb = f"{cfg.vp.name[cpu.abb]} {syscall}"
        else:
            abb = "None"
        graph_attrs = "<br/>".join(
            [
                f"<i>{k}</i>: {html.escape(str(v))}"
                for k, v in [
                    ("irq_on", cpu.irq_on),
                    (
                        "instance",
                        instance,
                    ),
                    ("abb", abb),
                    ("call_path", cpu.call_path),
                ]
            ]
        )
        graph_attrs = f"<font point-size='{size}'>{graph_attrs}</font>"
        attrs["label"] = f"<{label}<br/>{graph_attrs}>"
        return attrs

    def dump_sstg(self, sstg, extra=''):
        dot_graph = pydot.Dot(graph_type="digraph", label="SSTG")

        for state_vert in sstg.vertices():
            attrs = self._state_as_dot(
                sstg, state_vert
            )
            dot_state = pydot.Node(str(state_vert), **attrs)
            dot_graph.add_node(dot_state)
        for edge in sstg.edges():
            dot_graph.add_edge(
                pydot.Edge(
                    str(edge.source()),
                    str(edge.target()),
                    color="black",
                )
            )

        if extra:
            extra = f'.{extra}'
        dot_file = self.dump_prefix.get() + f"sstg{extra}.dot"
        dot_path = os.path.abspath(dot_file)
        os.makedirs(os.path.dirname(dot_path), exist_ok=True)
        dot_graph.write(dot_path)

        self._log.info(f"Write SSTG to {dot_path}.")

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

        s = sstg.add_vertex()
        sstg.vp.state[s] = os_state
        state_map = {os_state: s}

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
                if self.detailed_dump.get():
                    self.dump_sstg(sstg, extra=counter)

        run_sse(
            self._graph,
            self._graph.os,
            visitor=SSEVisitor(),
            logger=self._log,
        )

        if self.dump.get():
            self.dump_sstg(sstg)
