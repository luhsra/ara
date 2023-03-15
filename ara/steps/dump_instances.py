# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for DumpCFG."""
from .step import Step


class DumpInstances(Step):
    """Dump the InstanceGraph (for debugging purposes)."""

    def get_single_dependencies(self):
        return ['LLVMMap']

    def run(self):
        inst_file = f'{self.dump_prefix.get()}.dot'
        self._step_manager.chain_step({"name": "Printer",
                                       "dot": inst_file,
                                       "graph_name": "Instances",
                                       "subgraph": 'instances'})
