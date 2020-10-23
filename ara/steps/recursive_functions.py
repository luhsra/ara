"""Container for RecursiveFuntions."""
from ara.graph import Graph
from .step import Step

from graph_tool.topology import all_circuits

class RecursiveFunctions(Step):
    """Mark all function that are in the Callgraph as recursive or not."""

    def get_single_dependencies(self):
        return ["CallGraph"]

    def run(self):
        callgraph = self._graph.callgraph
        cfg = self._graph.cfg

        for circuit in all_circuits(callgraph):
            for circuit_node in circuit:
                callgraph.vp.recursive[callgraph.vertex(circuit_node)] = True

        if self.dump.get():
            dump_prefix = self.dump_prefix.get()
            assert dump_prefix
            uuid = self._step_manager.get_execution_id()
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": dump_prefix + f'{uuid}.dot',
                 "graph_name": 'Recusive functions',
                 "subgraph": 'callgraph'}
            )
