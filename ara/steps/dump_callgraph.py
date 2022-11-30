"""Container for DumpCallgraph."""
from .step import Step


class DumpCallgraph(Step):
    """Dump the Callgraph (for debugging purposes)."""

    def get_single_dependencies(self):
        return ['ICFG']

    def run(self):
        cg_file = f'{self.dump_prefix.get()}.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": cg_file,
                                       "graph_name": "Callgraph",
                                       "subgraph": 'callgraph'})
