"""Container for SSTGStats."""
from .step import Step

import json


class SSTGStats(Step):
    """Gather statistics about the System state transition graph."""

    def get_single_dependencies(self):
        return ["SSE"]

    def run(self):
        sstg = self._graph.sstg

        num_absss = sstg.num_vertices()
        num_transitions = sstg.num_edges()

        self._log.info(f"Number of AbSSs: {num_absss}")
        self._log.info(f"Number of transitions: {num_transitions}")

        if self.dump.get():
            with open(self.dump_prefix.get() + '.json', 'w') as f:
                values = {"num_absss": num_absss,
                          "num_transitions": num_transitions}
                json.dump(values, f, indent=4)
