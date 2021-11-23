"""Container for DumpCFG."""
from .step import Step


class DumpCFG(Step):
    """Dump the CFG (for debugging purposes)."""

    def get_single_dependencies(self):
        return ['LLVMMap']

    def run(self):
        abb_file = f'{self.dump_prefix.get()}.abbs.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": abb_file,
                                       "graph_name": "ABBs",
                                       "subgraph": 'abbs'})
        bb_file = f'{self.dump_prefix.get()}.bbs.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": bb_file,
                                       "graph_name": "BBs",
                                       "subgraph": 'bbs'})
