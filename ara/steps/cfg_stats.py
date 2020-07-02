"""Container for CFGStats."""
from ara.graph import ABBType, CFGView, CFType, Graph
from .step import Step

import graph_tool
import sys

class CFGStats(Step):
    """Gather statistics about the Control Flow Graph."""

    def get_single_dependencies(self):
        return ["IRReader"]

    def run(self):
        self._log.info("Executing CFGStats step.")
        cfg = self._graph.cfg

        # Count number of Nodes (ABBs + non implemented functions)
        num_abbs = 0;

        for v in cfg.vertices() :
            if self._graph.cfg.vp.is_function[v]:
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
        lcfg = CFGView(cfg, efilt=lambda e: cfg.ep.type[e] != CFType.icf)
        icfg = CFGView(cfg, efilt=lambda e: cfg.ep.type[e] != CFType.lcf)

        num_lcomp = 0
        lproperty_map, lhist = graph_tool.topology.label_components(lcfg,
                                                                    None,
                                                                    None,
                                                                    False)
        for comp in lhist :
            num_lcomp += 1
        self._log.info("Number of local components: " + str(num_lcomp))

        num_icomp = 0
        iproperty_map, ihist = graph_tool.topology.label_components(icfg,
                                                                    None,
                                                                    None,
                                                                    False)
        for comp in ihist :
            num_icomp += 1
        self._log.info(f"Number of interprocedural components: {num_icomp}")

        # Calculate cyclomatic complexities
        lv = num_ledges - num_abbs + 2 * num_lcomp
        iv = num_iedges - num_abbs + 2 * num_icomp

        self._log.info(f"Local cyclomatic complexity: {lv}")
        self._log.info(f"Interprocedural cyclomatic complexity: {iv}")
        # Only used for bulk testing
        sys.stdout.write(str(num_abbs) + " " + str(lv) + " " + str(iv) + "\n")
