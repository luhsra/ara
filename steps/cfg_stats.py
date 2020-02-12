"""Container for CFGStats."""
import graph

from native_step import Step
from .option import Option, Integer

import graph_tool


class CFGStats(Step):
    """Gather statistics about the Control Flow Graph."""

    def get_dependencies(self):
        return ["ABBMerge"]

    def run(self, g: graph.Graph):
        self._log.info("Executing CFGStats step.")
        num_cycles = 0;
        
        for c in graph_tool.topology.all_circuits(g.cfg,True) :
            num_cycles += 1

        self._log.info("Number of Cycles: " + str(num_cycles))
