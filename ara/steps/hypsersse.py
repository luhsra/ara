# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for HyperSSE."""
from ara.graph import Graph, CFG
from .step import Step
from .option import Option, Integer


class HyperSSE(Step):
    """Provides analysis of inter-vm communication."""
    dummy_option = Option(name="dummy_option",
                          help="An option to demonstrate options.",
                          ty=Integer())

    # TODO
    #def get_dependencies(self, _):
    #    return []
        # return ["MultiSSE"]
    def get_single_dependencies(self):
        return ["MultiSSE"]
    
    def run(self):
        self._log.info("Starting HyperSSE step.")
        opt = self.dummy_option.get()
        if opt:
            self._log.info(f"Option is {opt}.")

        # extract graphs
        cfg: CFG = self._graph.cfg
        callgraph = self._graph.callgraph
        os = self._graph.os
