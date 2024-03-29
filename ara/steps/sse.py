# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Fredo Nowak
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Jan Neugebauer
# SPDX-FileCopyrightText: 2021 Kenny Albes
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for SSE."""
from .step import Step
from .option import Option, String, Bool
from .cfg_traversal import Visitor, run_sse

import graph_tool
import os

from .printer import sstg_to_dot
from .util import open_with_dirs


class SSE(Step):
    """Run a single core SSE."""

    entry_point = Option(name="entry_point", help="system entry point",
                         ty=String())

    detailed_dump = Option(name="detailed_dump", help="Output the state graph every iteration (WARNING: produces _a lot of_ files).",
                           ty=Bool(),
                           default_value=False)

    def get_single_dependencies(self):
        return ["SysFuncts"] + self._graph.os.get_special_steps()

    def dump_sstg(self, sstg, extra):
        dot_file = self.dump_prefix.get() + f"sstg.{extra}.dot"
        dot_path = os.path.abspath(dot_file)
        dot_graph = sstg_to_dot(sstg, f"SSTG {extra}")
        with open_with_dirs(dot_path):
            dot_graph.write(dot_path)
        self._log.info(f"Write SSTG to {dot_path}.")

    def run(self):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")
        self._log.info(f"Analyzing entry point: '{entry_label}'")

        sstg = graph_tool.Graph()
        sstg.graph_properties["start"] = sstg.new_gp("long")
        sstg.vertex_properties["state"] = sstg.new_vp("object")
        sstg.edge_properties["syscall"] = sstg.new_ep("object")
        sstg.edge_properties["bcet"] = sstg.new_ep("int64_t", val=-1)
        sstg.edge_properties["wcet"] = sstg.new_ep("int64_t", val=-1)

        os_state = self._graph.os.get_initial_state(
            self._graph.cfg, self._graph.instances
        )

        first = sstg.add_vertex()
        sstg.vp.state[first] = os_state
        state_map = {hash(os_state): first}
        sstg.gp.start = int(first)

        assert len(os_state.cpus) == 1, "SSE does not support more than one CPU."

        class SSEVisitor(Visitor):
            PREVENT_MULTIPLE_VISITS = False
            CFG_CONTEXT = None

            @staticmethod
            def get_initial_state():
                return os_state

            @staticmethod
            def init_execution(_):
                return

            @staticmethod
            def schedule(new_states):
                return self._graph.os.schedule(new_states, [0])

            @staticmethod
            def add_state(new_state):
                s_hash = hash(new_state)
                if s_hash not in state_map:
                    s = sstg.add_vertex()
                    sstg.vp.state[s] = new_state
                    state_map[s_hash] = s
                    return True
                return False

            @staticmethod
            def add_transition(source, target):
                sstg.add_edge(state_map[hash(source)], state_map[hash(target)])

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

        # store result
        self._graph.sstg = sstg

        if self.dump.get():
            self._step_manager.chain_step(
                {
                    "name": "Printer",
                    "dot": self.dump_prefix.get() + "sstg.dot",
                    "graph_name": "SSTG",
                    "subgraph": "sstg",
                }
            )
