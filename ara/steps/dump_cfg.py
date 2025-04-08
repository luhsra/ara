# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for DumpCFG."""
from .step import Step
from .option import Option, String, Bool

class DumpCFG(Step):
    """Dump the CFG (for debugging purposes)."""

    dot = Option(name="dot",
                help="Path to a dot file.",
                ty=String(),
                default_value=None)

    add_legend = Option(name="add_legend",
                help="Add a legend to the graph. Currently only supports CFGs.",
                ty=Bool(),
                default_value=False)

    
    def get_single_dependencies(self):
        return ['LLVMMap']

    def run(self):
        dot = self.dot.get()
        if dot:
            abb_file = f'{self.dump_prefix.get()}{dot}..abbs.dot'
            bb_file = f'{self.dump_prefix.get()}{dot}.bbs.dot'
        else:
            abb_file = f'{self.dump_prefix.get()}.abbs.dot'
            bb_file = f'{self.dump_prefix.get()}.bbs.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": abb_file,
                                       "graph_name": "ABBs",
                                       "subgraph": 'abbs',
                                       "add_legend": self.add_legend.get()})
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": bb_file,
                                       "graph_name": "BBs",
                                       "subgraph": 'bbs',
                                       "add_legend": self.add_legend.get()})
