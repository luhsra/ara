"""Container for CallGraph."""
import graph_tool
import graph_tool.draw
import graph_tool.search
import graph_tool.util

import ara.graph as _graph

from .step import Step
from .option import Option, String


class CallGraph(Step):
    """Calculate the CallGraph for one entry point"""

    entry_point = Option(name="entry_point",
                         help="entry point for creation of the call graph",
                         ty=String())

    def get_single_dependencies(self):
        return [{"name": "ICFG", "entry_point": self.entry_point.get()},
                "FakeEntryPoint"]

    def _copy_props(self, g, old_v, new_v):
        """Copy the subtree properties."""
        g.vp.label[new_v] = g.vp.label[old_v].split('-')[0] + f"-{int(new_v)}"
        g.vp.func[new_v] = g.vp.func[old_v]
        g.vp.cfglink[new_v] = g.vp.cfglink[old_v]

    def _dup_subtree(self, cg, root):
        """Duplicate a subtree. Internally a DFS is used."""
        v_map = {}
        # duplicate root node
        new_root = cg.add_vertex()
        v_map[root] = new_root
        self._copy_props(cg, root, new_root)
        # duplicate tree below root
        for e in graph_tool.search.dfs_iterator(cg, root):
            new_v = cg.add_vertex()
            v_map[e.target()] = new_v
            self._copy_props(cg, e.target(), new_v)
            new_e = cg.add_edge(v_map[e.source()], new_v)
            cg.ep.label[new_e] = cg.ep.label[e]
        return new_root

    def _get_edge_label(self, cfg, caller):
        return "Call: " + cfg.vp.name[cfg.vertex(caller)]

    def _add_vertex(self, cg, cfg, name: str, caller=None, src=None):
        """Add a new vertex with name. Optionally link it with src.
        If the vertex is already present, its whole subtree is copied.

        Return the new vertex if it is created, None otherwise.

        Arguments:
        cg     -- call graph
        cfg    -- control flow graph
        name   -- name of the new call graph node (function name)
        caller -- caller ABB (if src is given)
        src    -- caller function
        """
        v = graph_tool.util.find_vertex(cg, cg.vp.func, name)
        if v and src is not None:
            # we find a duplicate
            other_v = self._dup_subtree(cg, v[0])
            cg.vp.cfglink[other_v] = caller
            e = cg.add_edge(src, other_v)
            cg.ep.label[e] = self._get_edge_label(cfg, caller)
            return None

        v = cg.add_vertex()
        cg.vp.label[v] = name + f"-{int(v)}"
        cg.vp.func[v] = name
        if src:
            cg.vp.cfglink[v] = caller
            e = cg.add_edge(src, v)
            cg.ep.label[e] = self._get_edge_label(cfg, caller)
        else:
            cg.vp.cfglink[v] = 0
        return v

    def visit(self, cfg, func, cg, cg_func):
        """Do a depth first search about the local control flow.
        Every time a call is found visit is called again.

        Arguments:
        icfg    -- CFG
        func    -- function node within the CFG (entry of the search)
        cg      -- call graph
        cg_func -- corresponding function to func within the call graph
        """
        for abb in cfg.get_abbs(func):
            if cfg.vp.type[abb] in [_graph.ABBType.call,
                                     _graph.ABBType.syscall]:
                for edge in cfg.vertex(abb).out_edges():
                    if cfg.ep.type[edge] == _graph.CFType.icf:
                        new_func = cfg.get_function(edge.target())
                        new_vert = self._add_vertex(cg, cfg,
                                                    cfg.vp.name[new_func],
                                                    abb, src=cg_func)
                        if new_vert:
                            self.visit(cfg, new_func, cg, new_vert)

    def run(self):
        entry_point = self.entry_point.get()
        if not entry_point:
            self._fail("Entry point must be given.")

        entry_func = self._graph.cfg.get_function_by_name(entry_point)

        cg = graph_tool.Graph()
        cg.vp["label"] = cg.new_vertex_property("string")
        cg.vp["func"] = cg.new_vertex_property("string")
        cg.vp["cfglink"] = cg.new_vertex_property("long")
        cg.ep["label"] = cg.new_edge_property("string")
        # add root vertex
        start = self._add_vertex(cg, self._graph.cfg, entry_point)

        self.visit(self._graph.cfg, entry_func, cg, start)

        self._graph.call_graphs[entry_point] = cg

        if self.dump.get():
            cg.save(self.dump_prefix.get() + entry_point + ".dot", fmt='dot')
