"""Container for CreateABBs."""
from ara.graph import NodeLevel, CFType, ABBType, edge_types, CFGView
from ara.util import has_path
from .step import Step
from .option import Option, String

from collections import defaultdict
from itertools import product
from dataclasses import dataclass
from typing import Set

from graph_tool import GraphView, Graph
from graph_tool.topology import dominator_tree, all_paths, label_components

import numpy


@dataclass
class ABBTail:
    exit_b: int
    body: Set[int]


class CreateABBs(Step):
    """Create ABBs from BBs."""

    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    def get_single_dependencies(self):
        return [{"name": "ICFG", "entry_point": self.entry_point.get()}]

    def _assign_sets(self, dom_tree, bbs):
        bb_sets = defaultdict(set)
        for bb in bbs:
            new_bbs = {bb} | bb_sets[bb]

            root = bb
            # add self to root chain
            while root != 0:
                bb_sets[root] |= new_bbs
                root = dom_tree[root]

        return bb_sets

    def _abb_counter(self):
        a = self._get_step_data(int)
        self._set_step_data(a + 1)
        return a

    def _add_abb(self, graph, func, entry, exit_v, body):
        cfg = self._graph.cfg
        name = cfg.vp.name
        abb = cfg.add_vertex()

        all_bbs = body | {entry, exit_v}

        # properties
        name[abb] = f"ABB{self._abb_counter()}"

        cfg.vp.type[abb] = cfg.vp.type[entry]
        cfg.vp.level[abb] = NodeLevel.abb
        cfg.vp.is_exit[abb] = any([cfg.vp.is_exit[bb] for bb in all_bbs])

        cfg.vp.is_exit_loop_head[abb] = cfg.vp.is_exit_loop_head[entry]
        cfg.vp.part_of_loop[abb] = cfg.vp.part_of_loop[entry]
        if cfg.vp.part_of_loop[entry]:
            # does the ABB consume the loop?
            if all([set(path).issubset(all_bbs) for path in all_paths(graph, entry, entry)]):
                cfg.vp.part_of_loop[abb] = False

        if cfg.vp.type[abb] in [ABBType.call, ABBType.syscall]:
            cfg.vp.files[abb] = cfg.vp.files[entry]
            cfg.vp.lines[abb] = cfg.vp.lines[entry]

        for bb in all_bbs:
            # connect abb and bb
            edge = cfg.add_edge(abb, bb)
            cfg.ep.type[edge] = CFType.a2b
            if bb == entry:
                cfg.ep.is_entry[edge] = True
            if bb == exit_v:
                cfg.vp.is_exit[bb] = bb == exit_v
        edge = cfg.add_edge(func, abb)
        cfg.ep.type[edge] = CFType.f2a
        cfg.ep.is_entry[edge] = cfg.ep.is_entry[cfg.edge(func, entry)]

        self._log.debug(f"Create abb {name[abb]} (Node {abb}), entry: {name[entry]}, exit: {name[exit_v]}, "
                        "consisting of "
                        f"{', '.join([name[x] for x in all_bbs])}")

        return abb

    def _add_icf_edges(self, abb, exit_v):
        # link icf edges
        cfg = self._graph.cfg
        icfg = edge_types(cfg, cfg.ep.type, CFType.icf)
        name = cfg.vp.name

        for e in icfg.vertex(exit_v).out_edges():
            tgt_abb = cfg.get_abb(e.target())
            lh = cfg.vp.is_exit_loop_head[exit_v]
            if tgt_abb and (lh or (not lh and abb != tgt_abb)):
                self._log.debug(f"ICFG edge from {name[abb]} "
                                f"to {name[tgt_abb]} (outgoing)")
                edge = icfg.edge(abb, tgt_abb, add_missing=True)
                cfg.ep.type[edge] = CFType.icf

    def _add_edges(self, abb, exit_v):
        cfg = self._graph.cfg
        lcfg = edge_types(cfg, cfg.ep.type, CFType.lcf)

        name = cfg.vp.name
        for e in lcfg.vertex(exit_v).out_edges():
            # find neighbor abb
            tgt_abb = cfg.get_abb(e.target())
            if not cfg.vp.is_exit_loop_head[exit_v] and abb == tgt_abb:
                continue
            self._log.debug(f"LCFG edge from {name[abb]} "
                            f"to {name[tgt_abb]} (outgoing)")
            edge = cfg.add_edge(abb, tgt_abb)
            cfg.ep.type[edge] = CFType.lcf

        self._add_icf_edges(abb, exit_v)

    def _gen_dom_tree(self, graph, reverse_graph=False):
        # We need to introduce a temporary fake entry vertex. This is not
        # easy on filtered graphs, so we do a copy.
        mapping = graph.new_vp("int64_t", vals=numpy.arange(graph.num_vertices()))
        g = Graph(graph, prune=True, vorder=mapping)
        if reverse_graph:
            g.set_reversed(True)

        entries = [x for x in g.vertices() if x.in_degree() == 0]

        root = g.add_vertex()
        for entry in entries:
            g.add_edge(root, entry)

        copy_dom = g.new_vp("int32_t", val=-1)
        dominator_tree(g, root, copy_dom)
        dom_tree = graph.new_vp("int64_t")

        back_map = {}
        for v in graph.vertices():
            back_map[mapping[v]] = v

        for v in graph.vertices():
            dominator = copy_dom[mapping[v]]
            if dominator == root or dominator == -1:
                continue
            dom_tree[v] = back_map[copy_dom[mapping[v]]]

        # name = self._graph.cfg.vp.name
        # self._log.error([(name[x], name[dom_tree[x]]) for x in graph.vertices() if dom_tree[x] != 0])

        return dom_tree

    def run(self):
        cfg = self._graph.cfg
        lcfg = edge_types(cfg, cfg.ep.type, CFType.lcf)
        cg = self._graph.callgraph
        f2a = edge_types(cfg, cfg.ep.type, CFType.f2a)
        name = cfg.vp.name

        entry_label = self.entry_point.get()
        entry_func = cfg.get_function_by_name(entry_label)

        def is_special(v):
            return cfg.vp.is_exit_loop_head[v] or \
                   cfg.vp.type[v] in [ABBType.syscall, ABBType.call]

        abbs = []
        for func in list(cfg.reachable_functs(entry_func, cg)):
            def err(args):
                return

            if f2a.vertex(func).out_degree() > 0:
                # function is already handled
                # It may, however possible that its exit ABB has new outgoing
                # ICF edges
                exit_abb = cfg.get_exit_abb(func)
                if exit_abb is not None:
                    self._add_icf_edges(exit_abb, cfg.get_exit_bb(exit_abb))
                continue
            self._log.warn(f"Handle {name[func]}")

            reachable_bbs = cfg.new_vp("bool", val=False)
            bbs = set()
            special = set()
            for v in cfg.get_function_bbs(func):
                reachable_bbs[v] = True
                if is_special(v):
                    special.add(v)
                else:
                    bbs.add(v)
            local = CFGView(lcfg, vfilt=reachable_bbs)
            entry = cfg.get_function_entry_bb(func)
            exit_v = cfg.get_function_exit_bb(func)

            d_graph = GraphView(local, efilt=lambda e: not is_special(e.target()))
            rd_graph = GraphView(local, efilt=lambda e: not is_special(e.source()))

            dom_tree = self._gen_dom_tree(d_graph)
            post_dom_tree = self._gen_dom_tree(rd_graph, reverse_graph=True)

            f_sets = self._assign_sets(dom_tree, bbs)
            r_sets = self._assign_sets(post_dom_tree, bbs)
            err(f"Dominators: {[(name[x], [name[z] for z in y]) for x, y in f_sets.items()]}")
            err(f"Postdominators: {[(name[x], [name[z] for z in y]) for x, y in r_sets.items()]}")

            abb_cands = {}  # key = (entry, exit), value = BBs in between
            absorbed = set()
            # iterate all bb pairs
            for a, b in product(bbs, repeat=2):
                if a in absorbed:
                    continue
                # if b dominates a and a postdominates b
                if b in f_sets[a] and a in r_sets[b]:
                    err(f"Found Candidate: {cfg.vp.name[a]} {cfg.vp.name[b]}")
                    # check for another bigger ABB already starting at a
                    if a in abb_cands and b in abb_cands[a].body | {a}:
                        err("Candidate is surrounded by a bigger one.")
                        continue
                    # define body of the a b block
                    if a != b:
                        body = f_sets[a] & r_sets[b] - {a, b}
                    else:
                        body = set()
                    err(f"Body: {body}")
                    # store as candidate
                    abb_cands[a] = ABBTail(exit_b=b, body=body)
                    # invalidate all bbs of the body
                    to_absorb = set(body)
                    if a != b:
                        to_absorb.add(b)
                    err(f"Absorbed blocks: {to_absorb}")
                    # delete smaller candidates
                    for n in to_absorb:
                        if n in abb_cands:
                            del abb_cands[n]
                    absorbed |= to_absorb

            for entry, tail in abb_cands.items():
                abb = self._add_abb(local, func, entry, tail.exit_b, tail.body)
                abbs.append((abb, tail.exit_b))
            for call in special:
                abb = self._add_abb(local, func, call, call, set())
                abbs.append((abb, call))

        # link edges
        for abb, exit_v in abbs:
            self._add_edges(abb, exit_v)

        # remap callgraph links to ABBs instead of BBs
        callgraph = self._graph.callgraph
        for e in callgraph.edges():
            bb = cfg.vertex(callgraph.ep.callsite[e])
            abb = cfg.get_abb(bb)
            if abb is not None:
                callgraph.ep.callsite[e] = abb
                callgraph.ep.callsite_name[e] = name[abb]

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
