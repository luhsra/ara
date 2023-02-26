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
