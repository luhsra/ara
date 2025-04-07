# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for DumpCFG."""
from .step import Step
from .option import Option, String


class DumpInstances(Step):
    """Dump the InstanceGraph (for debugging purposes)."""

    dot = Option(name="dot",
                help="Path to a dot file.",
                ty=String(),
                default_value=None)
    
    def get_single_dependencies(self):
        return ['LLVMMap']

    def run(self):
        dot = self.dot.get()
        if dot:
            inst_file = f'{self.dump_prefix.get()}{dot}.dot'
        else:
            inst_file = f'{self.dump_prefix.get()}.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": inst_file,
                                       "graph_name": "Instances",
                                       "subgraph": 'instances'})
