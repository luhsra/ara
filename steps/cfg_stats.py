"""Container for CFGStats."""
import graph

from native_step import Step
from .option import Option, Integer
from graph import ABBType

import graph_tool


class CFGStats(Step):
    """Gather statistics about the Control Flow Graph."""

    def get_dependencies(self):
        return ["IRReader"]

    def run(self, g: graph.Graph):
        self._log.info("Executing CFGStats step.")

        num_abbs = 0;

        for v in g.cfg.vertices() :
            if g.cfg.vp.type[v] in [ABBType.computation, ABBType.call, ABBType.syscall] :
                num_abbs += 1

        self._log.info("Number of ABBs: " + str(num_abbs))

        num_cycles = 0;
        
        for c in graph_tool.topology.all_circuits(g.cfg,True) :
            num_cycles += 1

        self._log.info("Number of Cycles: " + str(num_cycles))
