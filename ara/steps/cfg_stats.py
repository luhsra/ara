"""Container for CFGStats."""
from ara.graph import ABBType, CFGView, CFType, Graph, SyscallCategory
from .step import Step
from graph_tool.topology import label_components
from ara.os import get_syscalls

import graph_tool
import json
import sys
import numpy
import statistics

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

        num_abbs = abbs.num_vertices()
        num_syscalls = syscalls.num_vertices()
        num_calls = calls.num_vertices()
        num_computation = computation.num_vertices()
        num_functions = functs.num_vertices()
        num_ledges = lcfg.num_edges()
        num_iedges = icfg.num_edges()

        # syscall categories
        model_calls = dict([(x, getattr(cls, x).categories)
                            for x, cls in get_syscalls()])

        cat_counter = dict([(c, 0) for c in SyscallCategory])

        for syscall in syscalls.vertices():
            categories = model_calls[syscalls.get_syscall_name(syscall)]
            for cat in categories:
                cat_counter[cat] += 1

        # cyclomatic complexities
        _, ihist = label_components(icfg, None, None, False)
        num_icomp = len(ihist)

        lvs = []
        for func in functs.vertices():
            if not functs.vp.implemented[func]:
                continue
            component = cfg.new_vertex_property("bool")
            for abb in cfg.vertex(func).out_neighbors():
                assert not cfg.vp.is_function[abb]
                component[abb] = True
            func_cfg = CFGView(lcfg, vfilt=component)
            lv = func_cfg.num_edges() - func_cfg.num_vertices() + 1
            lvs.append(lv)
        lv = statistics.mean(lvs)
        lv_box = (min(lvs),
                  *[numpy.quantile(lvs, x) for x in [0.25, 0.5, 0.75]],
                  max(lvs))

        _, ihist = label_components(icfg, None, None, False)
        num_icomp = len(ihist)
        iv = num_iedges - num_abbs + 2 * num_icomp

        self._log.info(f"Number of ABBs: {num_abbs}")
        self._log.info(f"Number of syscalls: {num_syscalls}")
        self._log.info(f"Number of calls: {num_calls}")
        self._log.info(f"Number of computation: {num_computation}")
        self._log.info(f"Number of functions: {num_functions}")
        self._log.info(f"Number of local edges: {num_ledges}")
        self._log.info(f"Number of interp. edges: {num_iedges}")
        self._log.info(f"Local average cyclomatic complexity: {lv}")
        self._log.info(f"Local boxplot cyclomatic complexity: {lv_box}")
        self._log.info(f"Interprocedural cyclomatic complexity: {iv}")
        for cat, count in cat_counter.items():
            self._log.info(f"Number of syscalls for category {cat.name}: {count}")

        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            stat_file = f'{uuid}.json'
            stat_file = self.dump_prefix.get() + stat_file

            with open(stat_file, 'w') as f:
                values = {"num_abbs": num_abbs,
                           "num_syscalls": num_syscalls,
                           "num_calls": num_calls,
                           "num_computation": num_computation,
                           "num_functions": num_functions,
                           "num_local_edges": num_ledges,
                           "num_interprocedural_edges": num_iedges,
                           "local_average_cyclomatic_complexity": lv,
                           "local_boxplot_cyclomatic_complexity": lv_box,
                           "interprocedural_cyclomatic_complexity": iv}
                for cat, count in cat_counter.items():
                    values[f"num_category_{cat.name}"] = count
                json.dump(values, f, indent=4)
