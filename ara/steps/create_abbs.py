"""Container for CreateABBs."""
from ara.graph import Graph, NodeLevel, CFType, ABBType
from .step import Step
from .option import Option, Integer

from collections import defaultdict


class CreateABBs(Step):
    """Create ABBs from BBs. Currently, this is an 1 to 1 mapping."""

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def run(self):
        abb_counter = 0

        bb2abb = {}

        cfg = self._graph.cfg
        bbs = self._graph.bbs

        bb2abb = defaultdict(lambda: cfg.add_vertex())

        for bb in bbs.vertices():
            bb = cfg.vertex(bb)
            abb = bb2abb[bb]

            # properties
            cfg.vp.name[abb] = f"ABB{abb_counter}"
            abb_counter += 1

            cfg.vp.type[abb] = cfg.vp.type[bb]
            cfg.vp.level[abb] = NodeLevel.abb
            cfg.vp.is_exit[abb] = cfg.vp.is_exit[bb]
            cfg.vp.is_exit_loop_head[abb] = cfg.vp.is_exit_loop_head[bb]
            cfg.vp.part_of_loop[abb] = cfg.vp.part_of_loop[bb]

            if cfg.vp.type[abb] in [ABBType.call, ABBType.syscall]:
                cfg.vp.file[abb] = cfg.vp.file[bb]
                cfg.vp.line[abb] = cfg.vp.line[bb]

            # edges
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
                else:
                    assert False, "Unexpected edge type. Something is wrong."
            edge = cfg.add_edge(abb, bb)
            cfg.ep.type[edge] = CFType.a2b
            # since this is an 1 to 1 mapping, the BB is always an entry.
            cfg.ep.is_entry[edge] = True
