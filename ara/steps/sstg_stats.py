# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for SSTGStats."""
from .stats import StatsStep, StatData


class SSTGStats(StatsStep):
    """Gather statistics about the System state transition graph."""

    def get_single_dependencies(self):
        return ["SSE"]

    def run(self):
        sstg = self._graph.sstg

        data = [
            StatData(key="AbSSs", value=sstg.num_vertices()),
            StatData(key="transitions", value=sstg.num_edges())
        ]

        self._print_and_store(data)
