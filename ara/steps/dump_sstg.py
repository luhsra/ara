"""Container for DumpSSTG."""
from .step import Step


class DumpSSTG(Step):
    """Dump the SSTG (for debugging purposes)."""

    def get_single_dependencies(self):
        return ['SSE']

    def run(self):
        sstg_file = f'{self.dump_prefix.get()}.sstg.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": sstg_file,
                                       "graph_name": "SSTG",
                                       "subgraph": 'sstg'})
        rsstg_file = f'{self.dump_prefix.get()}.reduced_sstg.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": rsstg_file,
                                       "graph_name": "Reduced SSTG",
                                       "subgraph": 'reduced_sstg'})
