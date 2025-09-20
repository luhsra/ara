# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for DumpCallgraph."""
from .step import Step
from .option import Option, String, Bool

class DumpCallgraph(Step):
    """Dump the Callgraph (for debugging purposes)."""

    dot = Option(name="dot",
                help="Path to a dot file.",
                ty=String(),
                default_value=None)
    
    def get_single_dependencies(self):
        return ['ICFG']

    def run(self):

        dot = self.dot.get()
        if dot:
            path = self.dump_prefix.get().split(".")[0]
            cg_file = f'{path}.{dot}.complete.dot'
        else:
            cg_file = f'{self.dump_prefix.get()}.complete.dot'

        self._step_manager.chain_step({"name": "Printer",
                                       "dot": cg_file,
                                       "graph_name": "Callgraph",
                                       "subgraph": 'callgraph'})
        
        if dot:
            path = self.dump_prefix.get().split(".")[0]
            cg_file = f'{path}.{dot}.syscalls.dot'
        else:
            cg_file = f'{self.dump_prefix.get()}.syscalls.dot'

        self._step_manager.chain_step({"name": "Printer",
                                       "dot": cg_file,
                                       "graph_name": "Callgraph (only syscalls)",
                                       "subgraph": 'sysrel_callgraph'})
