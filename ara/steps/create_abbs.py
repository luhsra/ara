"""Container for CreateABBs."""
from ara.graph import NodeLevel, CFType, ABBType
from .step import Step
from .option import Option, String

from collections import defaultdict


class CreateABBs(Step):
    """Create ABBs from BBs. Currently, this is an 1 to 1 mapping."""

    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        return [{"name": "ICFG", "entry_point": self.entry_point.get()}]

    def run(self):
        cfg = self._graph.cfg
        cg = self._graph.callgraph

        entry_label = self.entry_point.get()
        entry_func = cfg.get_function_by_name(entry_label)

        def abb_counter():
            a = self._get_step_data(int)
            self._set_step_data(a + 1)
            return a

        # map for lcf edges
        bb2abb = defaultdict(lambda: cfg.add_vertex())
        new_abbs = set()

        self._log.debug(f"Handle {entry_label}")

        # store all BBs in a list to prevent changing of the graph while
        # iterating it at the same time
        for bb in list(cfg.reachable_bbs(entry_func, cg)):
            if cfg.get_abb(bb) is not None:
                continue

            bb = cfg.vertex(bb)
            abb = bb2abb[bb]

            # properties
            cfg.vp.name[abb] = f"ABB{abb_counter()}"

            cfg.vp.type[abb] = cfg.vp.type[bb]
            cfg.vp.level[abb] = NodeLevel.abb
            cfg.vp.is_exit[abb] = cfg.vp.is_exit[bb]
            cfg.vp.is_exit_loop_head[abb] = cfg.vp.is_exit_loop_head[bb]
            cfg.vp.part_of_loop[abb] = cfg.vp.part_of_loop[bb]

            if cfg.vp.type[abb] in [ABBType.call, ABBType.syscall]:
                cfg.vp.file[abb] = cfg.vp.file[bb]
                cfg.vp.line[abb] = cfg.vp.line[bb]

            # function and lcf edges
            for bb_edge in bb.in_edges():
                if cfg.ep.type[bb_edge] == CFType.f2b:
                    edge = cfg.add_edge(bb_edge.source(), abb)
                    cfg.ep.type[edge] = CFType.f2a
                    cfg.ep.is_entry[edge] = cfg.ep.is_entry[bb_edge]
                elif cfg.ep.type[bb_edge] == CFType.lcf:
                    src = cfg.get_abb(bb_edge.source())
                    if src is None:
                        src = bb2abb[bb_edge.source()]
                    edge = cfg.add_edge(src, abb)
                    cfg.ep.type[edge] = CFType.lcf
                elif cfg.ep.type[bb_edge] == CFType.icf:
                    # do not handle these
                    pass
                else:
                    assert False, "Unexpected edge type. Something is wrong."

            # connect abb and bb
            edge = cfg.add_edge(abb, bb)
            cfg.ep.type[edge] = CFType.a2b
            # since this is an 1 to 1 mapping, the BB is always an entry.
            cfg.ep.is_entry[edge] = True

            new_abbs.add(abb)

        # link icf edges
        icf_edges = set()
        for abb in new_abbs:
            bb = cfg.get_single_bb(abb)
            for bb_edge in bb.out_edges():
                if cfg.ep.type[bb_edge] == CFType.icf:
                    src = abb
                    tgt = cfg.get_abb(bb_edge.target())
                    if tgt and (src, tgt) not in icf_edges:
                        self._log.debug(f"ICFG edge from {cfg.vp.name[src]} "
                                        f"to {cfg.vp.name[tgt]} (outgoing)")
                        edge = cfg.add_edge(src, tgt)
                        cfg.ep.type[edge] = CFType.icf
                        icf_edges.add((src, tgt))
            for bb_edge in bb.in_edges():
                if cfg.vp.name[abb] == "ABB4":
                    self._log.debug(f"IN EDGE, TYPE {CFType(cfg.ep.type[bb_edge])}")
                if cfg.ep.type[bb_edge] == CFType.icf:
                    src = cfg.get_abb(bb_edge.source())
                    tgt = abb
                    if src and (src, tgt) not in icf_edges:
                        self._log.debug(f"ICFG edge from {cfg.vp.name[src]} "
                                        f"to {cfg.vp.name[tgt]} (ingoing)")
                        edge = cfg.add_edge(src, tgt)
                        cfg.ep.type[edge] = CFType.icf
                        icf_edges.add((src, tgt))

        # remap callgraph links to ABBs instead of BBs
        callgraph = self._graph.callgraph
        for e in callgraph.edges():
            bb = cfg.vertex(callgraph.ep.callsite[e])
            abb = cfg.get_abb(bb)
            if abb is not None:
                callgraph.ep.callsite[e] = abb
                callgraph.ep.callsite_name[e] = cfg.vp.name[abb]

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + "cfg.dot",
                 "graph_name": 'CFG with merged ABBs',
                 "subgraph": 'abbs'}
            )

            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + "callgraph.dot",
                 "graph_name": 'CallGraph with merged ABBs',
                 "subgraph": 'callgraph'}
            )
