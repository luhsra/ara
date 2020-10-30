"""Container for RecursiveFuntions."""
from ara.graph import Graph
from .step import Step

from graph_tool.topology import all_paths

class RecursiveFunctions(Step):
    """Mark all function that are in the Callgraph as recursive or not."""

    def get_single_dependencies(self):
        return ["CallGraph"]

    def run(self):
        callgraph = self._graph.callgraph
        cfg = self._graph.cfg

        visited = set()

        for v in callgraph.vertices():
            if v in visited:
                continue
            for path in all_paths(callgraph, v, v):
                for circuit_node in path:
                    callgraph.vp.recursive[callgraph.vertex(circuit_node)] = True
                    visited.add(circuit_node)

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + '.dot',
                 "graph_name": 'Recusive functions',
                 "subgraph": 'callgraph'}
            )
