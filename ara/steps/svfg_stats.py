# SPDX-FileCopyrightText: 2022 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for SVFGStats."""
from .stats import StatsStep, StatData


class SVFGStats(StatsStep):
    """Gather statistics about the SVFG."""

    def get_single_dependencies(self):
        return ["SVFAnalyses"]

    def run(self):
        svfg = self._graph.svfg

        data = [
            StatData(key="vertices", value=svfg.num_vertices()),
            StatData(key="edges", value=svfg.num_edges())
        ]

        self._print_and_store(data)
