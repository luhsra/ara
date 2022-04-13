"""Container for Syscall."""
from ara.graph import ABBType, CFType, CFGView
from .step import Step
from .option import Option, String

from enum import IntEnum
from graph_tool import GraphView

import logging


class ICFG(Step):
    """Map interprocedural edges.

    It maps only system relevant functions.
    """
    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    class _ET(IntEnum):
        IN = 0
        OUT = 1
        STD = 2

    def get_single_dependencies(self):
        return [{"name": "CallGraph", "entry_point": self.entry_point.get()},
                "SystemRelevantFunctions"]

    def run(self):
        entry_label = self.entry_point.get()
        entry_func = self._graph.cfg.get_function_by_name(entry_label)

        cfg = self._graph.cfg
        icfg = CFGView(self._graph.bbs, efilt=cfg.ep.type.fa == CFType.icf)
        lcfg = CFGView(self._graph.bbs, efilt=cfg.ep.type.fa == CFType.lcf)
        cg = self._graph.callgraph
        sys_rel_cg = GraphView(cg, vfilt=cg.vp.syscall_category_every)

        link_counter = 0
        callsite_counter = 0

        to_s = {
            ICFG._ET.IN: "ingoing",
            ICFG._ET.OUT: "outgoing",
        }

        for cur_func in cfg.reachable_functs(entry_func, cg):
            self._log.debug(f"Analyzing function {cfg.vp.name[cur_func]}.")

            to_be_linked = []
            skip_func = False

            for bb in cfg.get_function_bbs(cur_func):
                if (icfg.vertex(bb).out_degree() + icfg.vertex(bb).in_degree() > 0):
                    # function already handled in a previous ICFG run
                    skip_func = True
                    break
                # find other functions
                linked = False
                if cfg.vp.type[bb] in [ABBType.syscall, ABBType.call]:
                    try:
                        cg_vtx = sys_rel_cg.vertex(cfg.vp.call_graph_link[cur_func])
                        callsites = cg_vtx.out_edges()
                    except ValueError:
                        callsites = iter(list())

                    callsite_counter += 1
                    for callsite in callsites:
                        if sys_rel_cg.ep.callsite[callsite] == bb:
                            # for all callsites in the callgraph belonging to
                            # this BB
                            callee = sys_rel_cg.vp.function[callsite.target()]
                            self._log.debug("Found system relevant call "
                                            f"to {cfg.vp.name[callee]}.")
                            entry = cfg.get_entry_bb(cfg.vertex(callee))
                            to_be_linked.append((ICFG._ET.IN, bb, entry))
                            link_counter += 1
                            linked = True
                            assert lcfg.vertex(bb).out_degree() == 1
                            n_bb = next(lcfg.vertex(bb).out_neighbors())
                            exit_bb = cfg.get_function_exit_bb(cfg.vertex(callee))
                            if exit_bb:
                                to_be_linked.append(
                                    (ICFG._ET.OUT, exit_bb, n_bb)
                                )
                    if not linked:
                        cfg.vp.type[bb] = ABBType.computation
                if not linked:
                    # link local cfg
                    for n_bb in lcfg.vertex(bb).out_neighbors():
                        to_be_linked.append((ICFG._ET.STD, bb, n_bb))

            if skip_func:
                continue

            # link abbs
            for ty, src, target in to_be_linked:
                # some logging output
                if self._log.getEffectiveLevel() <= logging.DEBUG and ty in [ICFG._ET.IN, ICFG._ET.OUT]:
                    s = cfg.vp.name[src]
                    t = cfg.vp.name[target]
                    self._log.debug(f"Add {to_s[ty]} edge from {s} to {t}.")
                edge = cfg.add_edge(src, target)
                cfg.ep.type[edge] = CFType.icf

        self._log.info(
            f"Link {callsite_counter} callsites with {link_counter} functions."
        )

        if self.dump.get():
            dot_file = f'{self.dump_prefix.get()}{entry_label}.dot'
            name = f"ICFG (Function: {entry_label})"
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": name,
                                           "entry_point": entry_label,
                                           "from_entry_point": True,
                                           "subgraph": 'bbs'})
