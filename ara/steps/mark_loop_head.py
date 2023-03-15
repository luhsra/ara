# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for MarkLoopHead."""
from ara.graph import CFType, CFGView
from ara.util import dominates
from .step import Step
from .option import Option, String

from graph_tool.topology import dominator_tree


class MarkLoopHead(Step):
    """Itereate all ABBs marking its loop heads."""

    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        return [{"name": "CreateABBs", "entry_point": self.entry_point.get()}]

    def run(self):
        cfg = self._graph.cfg
        lcfg = self._graph.lcfg
        cg = self._graph.callgraph

        entry_label = self.entry_point.get()
        entry_func = cfg.get_function_by_name(entry_label)

        f2a = CFGView(cfg, efilt=cfg.ep.type.fa == CFType.f2a)

        for func in cfg.reachable_functs(entry_func, cg):
            self._log.debug(f"Function {cfg.vp.name[cfg.vertex(func)]}")

            local = lcfg.new_vp("bool")
            for v in f2a.vertex(func).out_neighbors():
                local[v] = True
            llcfg = CFGView(lcfg, vfilt=local)
            entry = cfg.get_entry_abb(func)

            dom_tree = dominator_tree(llcfg, llcfg.vertex(entry))

            for abb in CFGView(llcfg, vfilt=llcfg.vp.part_of_loop).vertices():
                # we need to find the loop head. Therefore we try to find the
                # back edge by search for an edge from a to b where b dominates
                # a.
                abb = llcfg.vertex(abb)
                for e in abb.in_edges():
                    if dominates(dom_tree, abb, e.source()):
                        cfg.vp.loop_head[cfg.vertex(abb)] = True
                        cfg.ep.back_edge[e] = True

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + "dot",
                 "graph_name": 'CFG with marked function heads',
                 "subgraph": 'abbs'}
            )
