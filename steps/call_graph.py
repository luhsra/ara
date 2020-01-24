"""Container for CallGraph."""
import graph

import graph_tool
import graph_tool.draw
import graph_tool.search
import graph_tool.util

from native_step import Step
from .option import Option, String


class CallGraph(Step):
    """Calculate the CallGraph for one entry point"""

    def _fill_options(self):
        self.entry_point = Option(name="entry_point",
                                  help="entry point for creation of the call graph",
                                  step_name=self.get_name(),
                                  ty=String())
        self.opts += [self.entry_point]

    def get_dependencies(self):
        return ["ICFG"]

    def _copy_props(self, g, old_v, new_v):
        """Copy the subtree properties."""
        g.vp.label[new_v] = g.vp.label[old_v]
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
            cg.add_edge(v_map[e.source()], new_v)
        return new_root

    def _add_vertex(self, cg, name, caller, src=None):
        """Add a new vertex with name. Optionally link it with src.
        If the vertex is already present, its whole subtree is copied.
        """
        v = graph_tool.util.find_vertex(cg, cg.vp.label, name)
        if v and src is not None:
            # we find a duplicate
            other_v = self._dup_subtree(cg, v[0])
            cg.vp.cfglink[other_v] = caller
            cg.add_edge(src, other_v)
            return None, True

        v = cg.add_vertex()
        cg.vp.label[v] = name
        cg.vp.cfglink[v] = caller
        if src:
            cg.add_edge(src, v)
        return v, False

    def visit(self, lcfg, icfg, cg, cg_vertex, abb):
        """Do a depth first search about the local control flow.
        Every time a call is found visit is called again.
        """
        for e in graph_tool.search.dfs_iterator(lcfg, abb):
            if lcfg.vp.type[e.source()] in [graph.ABBType.call,
                                            graph.ABBType.syscall]:
                for target in icfg.vertex(e.source()).out_neighbors():
                    func = icfg.vp.name[icfg.get_function(target)]
                    new_vert, visited = self._add_vertex(cg, func, e.source(),
                                                         src=cg_vertex)
                    if not visited:
                        self.visit(lcfg, icfg, cg, new_vert, target)

    def run(self, g: graph.Graph):
        entry_point = self.entry_point.get()
        if not entry_point:
            self._fail("Entry point must be given.")

        icfg = graph.CFGView(g.cfg, efilt=g.cfg.ep.type.fa == graph.CFType.icf)
        lcfg = graph.CFGView(g.cfg, efilt=g.cfg.ep.type.fa == graph.CFType.lcf)

        entry_func = g.cfg.get_function_by_name(entry_point)
        entry_abb = g.cfg.get_entry_abb(entry_func)

        cg = graph_tool.Graph()
        cg.vp["label"] = cg.new_vertex_property("string")
        cg.vp["cfglink"] = cg.new_vertex_property("long")
        # add root vertex
        start, _ = self._add_vertex(cg, entry_point, entry_abb)

        self.visit(lcfg, icfg, cg, start, entry_abb)

        g.call_graphs[entry_point] = cg

        if self.dump.get():
            cg.save("CallGraph." + entry_point + ".dot", fmt='dot')
