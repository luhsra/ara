"""Container for CFGStats."""
from ara.graph import ABBType, CFGView, CFType, Graph
from .step import Step
from graph_tool.topology import label_components

import graph_tool
import json
import sys
import numpy

class CFGStats(Step):
    """Gather statistics about the Control Flow Graph."""

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def run(self):
        cfg = self._graph.cfg
        icfg = CFGView(cfg, efilt=cfg.ep.type.fa == CFType.icf)
        lcfg = CFGView(cfg, efilt=cfg.ep.type.fa == CFType.lcf)
        syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)
        calls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.call)
        computation = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.computation)
        functs = CFGView(cfg, vfilt=cfg.vp.is_function)
        abbs = CFGView(cfg,
                       vfilt=numpy.logical_and(cfg.vp.type.fa != ABBType.not_implemented,
                                               numpy.logical_not(cfg.vp.is_function.fa)))

        for abb in abbs.vertices():
            print("abb", abbs.vp.name[abb])

        num_abbs = abbs.num_vertices()
        num_syscalls = syscalls.num_vertices()
        num_calls = calls.num_vertices()
        num_computation = computation.num_vertices()
        num_functions = functs.num_vertices()
        num_ledges = lcfg.num_edges()
        num_iedges = icfg.num_edges()

        # components
        _, lhist = label_components(lcfg, None, None, False)
        num_lcomp = len(lhist)

        _, ihist = label_components(icfg, None, None, False)
        num_icomp = len(ihist)

        # Calculate cyclomatic complexities
        lv = num_ledges - num_abbs + 2 * num_lcomp
        iv = num_iedges - num_abbs + 2 * num_icomp

        self._log.info(f"Number of ABBs: {num_abbs}")
        self._log.info(f"Number of syscalls: {num_syscalls}")
        self._log.info(f"Number of calls: {num_calls}")
        self._log.info(f"Number of computation: {num_computation}")
        self._log.info(f"Number of functions: {num_functions}")
        self._log.info(f"Number of local edges: {num_ledges}")
        self._log.info(f"Number of interp. edges: {num_iedges}")
        self._log.info(f"Number of local components: {num_lcomp}")
        self._log.info(f"Number of interprocedural components: {num_icomp}")
        self._log.info(f"Local cyclomatic complexity: {lv}")
        self._log.info(f"Interprocedural cyclomatic complexity: {iv}")

        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            stat_file = f'{uuid}.json'
            stat_file = self.dump_prefix.get() + stat_file

            with open(stat_file, 'w') as f:
                json.dump({"num_abbs": num_abbs,
                           "num_syscalls": num_syscalls,
                           "num_calls": num_calls,
                           "num_computation": num_computation,
                           "num_functions": num_functions,
                           "num_local_edges": num_ledges,
                           "num_interprocedural_edges": num_iedges,
                           "num_local_components": num_lcomp,
                           "num_interprocedural_components": num_icomp,
                           "local_cyclomatic_complexity": lv,
                           "interprocedural_cyclomatic_complexity": iv}, f,
                          indent=4)
