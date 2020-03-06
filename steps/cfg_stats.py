"""Container for CFGStats."""
import graph

from native_step import Step
from .option import Option, Integer
from graph import ABBType
from graph import CFType

import graph_tool
import sys

class CFGStats(Step):
    """Gather statistics about the Control Flow Graph."""

    def get_dependencies(self):
        return ["IRReader"]

    def run(self, g: graph.Graph):
        self._log.info("Executing CFGStats step.")
        cfg = g.cfg

        # Count number of Nodes (ABBs + non implemented functions)
        num_abbs = 0;

        for v in cfg.vertices() :
            if g.cfg.vp.is_function[v]:
                continue
            num_abbs += 1

        self._log.info("Number of ABBs: " + str(num_abbs))

        # Count number of control flow sensitive edges

        num_ledges = 0;
        num_iedges = 0;

        for e in cfg.edges() :
            if cfg.ep.type[e] == CFType.lcf:
                num_ledges += 1
            if cfg.ep.type[e] == CFType.icf:
                num_iedges += 1

        self._log.info("Number of local edges: " + str(num_ledges))
        self._log.info("Number of interp. edges: " + str(num_iedges))

        # Count number of connected components
        lcfg = graph.CFGView(cfg, efilt=lambda e: cfg.ep.type[e] != graph.CFType.icf)
        icfg = graph.CFGView(cfg, efilt=lambda e: cfg.ep.type[e] != graph.CFType.lcf)

        num_lcomp = 0
        lproperty_map, lhist = graph_tool.topology.label_components(lcfg, None, None, False)
        for comp in lhist :
            num_lcomp += 1
        self._log.info("Number of local components: " + str(num_lcomp))

        num_icomp = 0
        iproperty_map, ihist = graph_tool.topology.label_components(icfg, None, None, False)
        for comp in ihist :
            num_icomp += 1
        self._log.info("Number of interprocedural components: " + str(num_icomp))

        # Calculate cyclomatic complexities
        lv = num_ledges - num_abbs + 2 * num_lcomp
        iv = num_iedges - num_abbs + 2 * num_icomp

        self._log.info("Local cyclomatic complexity: " + str(lv))
        self._log.info("Interprocedural cyclomatic complexity: " + str(iv))
        # Only used for bulk testing
        sys.stdout.write(str(num_abbs) + " " + str(lv) + " " + str(iv) + "\n")
