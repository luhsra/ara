"""Container for SVFGStats."""
import json
from .step import Step

class SVFGStats(Step):
    """Gather statistics about the SVFG."""

    def get_single_dependencies(self):
        return ["SVFAnalyses"]

    def run(self):
        svfg = self._graph.svfg

        num_vertices = svfg.num_vertices()
        num_edges = svfg.num_edges()

        self._log.info(f"Number of vertices: {num_vertices}")
        self._log.info(f"Number of edges: {num_edges}")

        if self.dump.get():
            with open(self.dump_prefix.get() + '.json', 'w') as f:
                values = {"num_vertices": num_vertices,
                          "num_edges": num_edges}
                json.dump(values, f, indent=4)
