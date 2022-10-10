"""Container for CFGStats."""
from ara.graph import ABBType, CFGView, CFType, Graph, SyscallCategory, NodeLevel
from .step import Step
from .util import open_with_dirs
from graph_tool.topology import label_components

import json
import numpy
import statistics


class CFGStats(Step):
    """Gather statistics about the Control Flow Graph."""

    def get_single_dependencies(self):
        return ["CreateABBs", "Syscall"]

    def run(self):
        cfg = self._graph.cfg
        icfg = self._graph.icfg
        lcfg = self._graph.lcfg
        bbs = self._graph.bbs
        bb_calls = CFGView(bbs, vfilt=cfg.vp.type.fa == ABBType.call)
        abbs = self._graph.abbs
        syscalls = CFGView(abbs, vfilt=cfg.vp.type.fa == ABBType.syscall)
        calls = CFGView(abbs, vfilt=cfg.vp.type.fa == ABBType.call)
        computation = CFGView(abbs, vfilt=cfg.vp.type.fa == ABBType.computation)
        functs = self._graph.functs

        num_bbs = bbs.num_vertices()
        num_bb_calls = bb_calls.num_vertices()
        num_abbs = abbs.num_vertices()
        num_syscalls = syscalls.num_vertices()
        num_calls = calls.num_vertices()
        num_computation = computation.num_vertices()
        num_functions = functs.num_vertices()
        num_ledges = lcfg.num_edges()
        num_iedges = icfg.num_edges()

        # syscall categories
        syscalls = {}
        if self._graph.os is not None:
            syscalls = self._graph.os.detected_syscalls()
        model_calls = dict([(n, o.categories) for n, o in syscalls.items()])

        cat_counter = dict([(c, 0) for c in SyscallCategory])

        # TODO: should a syscall with a corresponding alias counted as two or one syscall ?
        # Here it is counted as two:
        for syscall_name, _ in syscalls.items():
            categories = model_calls[syscall_name]
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
                if cfg.vp.level[abb] == NodeLevel.abb:
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

        self._log.info(f"Number of BBs: {num_bbs}")
        self._log.info(f"Number of ABBs: {num_abbs}")
        self._log.info(f"Number of syscalls: {num_syscalls}")
        self._log.info(f"Number of calls: {num_calls}")
        self._log.info(f"Number of BB calls: {num_bb_calls}")
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
            with open_with_dirs(self.dump_prefix.get() + '.json', 'w') as f:
                values = {"num_bbs": num_bbs,
                          "num_abbs": num_abbs,
                          "num_syscalls": num_syscalls,
                          "num_calls": num_calls,
                          "num_bb_calls": num_bb_calls,
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
