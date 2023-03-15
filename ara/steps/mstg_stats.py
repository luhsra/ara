# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for SSTGStats."""
from .stats import StatsStep, StatData
from ara.graph import StateType


class MSTGStats(StatsStep):
    """Gather statistics about the Multi-state transition graph."""

    def get_single_dependencies(self):
        return ["MultiSSE"]

    def run(self):
        mstg = self._graph.mstg

        data = [
            StatData(key="vertices", value=mstg.num_vertices()),
            StatData(key="edges", value=mstg.num_edges()),
        ]

        sp_g = mstg.vertex_type(StateType.entry_sync, StateType.exit_sync)
        data.append(StatData(key="SPs", value=sp_g.num_vertices()))

        labss_g = mstg.vertex_type(StateType.state)
        data.append(StatData(key="LAbSSs", value=labss_g.num_vertices()))

        self._print_and_store(data)
