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
        cfg = g.cfg

        # Calculate number of ABBs
        num_abbs = 0;

        for v in cfg.vertices() :
            if cfg.vp.type[v] in [ABBType.computation, ABBType.call, ABBType.syscall] :
                num_abbs += 1

        self._log.info("Number of ABBs: " + str(num_abbs))

        # Calculate number of Cycles
        num_cycles = 0;
        
        for c in graph_tool.topology.all_circuits(cfg,True) :
            num_cycles += 1

        self._log.info("Number of Cycles: " + str(num_cycles))

        # Calculate cyclomatic complexity
        num_components = 0
        property_map, hist = graph_tool.topology.label_components(cfg, None, cfg.is_directed(), False)
        for comp in hist :
            num_components += 1
        v = cfg.num_edges() - cfg.num_vertices() + 2 * num_components

        self._log.info("Cyclomatic complexity: " + str(v))

