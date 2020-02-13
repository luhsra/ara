"""Container for Printer."""
import graph
from .option import Option, String, Choice, Bool

from native_step import Step

import pydot

import graph_tool.draw


class Printer(Step):
    """Print graphs to dot."""

    SHAPES = {
        graph.ABBType.computation: ("oval", "", "blue"),
        graph.ABBType.call: ("box", "", "red"),
        graph.ABBType.syscall: ("box", "rounded", "green")
    }

    def _fill_options(self):
        self.dot = Option(name="dot",
                          help="Path to a dot file, '-' will write to stdout.",
                          step_name=self.get_name(),
                          ty=String())
        self.graph_name = Option(name="graph_name",
                                 help="Name of the graph.",
                                 step_name=self.get_name(),
                                 ty=String())
        self.print_to_log = Option(name="print_to_log",
                                   help="Dump graph to logger.",
                                   step_name=self.get_name(),
                                   ty=Bool())
        self.subgraph = Option(name="subgraph",
                               help="Choose, what subgraph should be printed.",
                               step_name=self.get_name(),
                               ty=Choice("abbs"))
        self.opts += [self.dot, self.graph_name, self.dump, self.subgraph]

    def print_abbs(self, g):
        dot = self.dot.get()
        if not dot:
            return

        if self.print_to_log.get():
            self._log.error("Not supported yet.")
            return

        name = self.graph_name.get()
        if not name:
            name = ''

        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        for function in g.cfg.vertices():
            if not g.cfg.vp.is_function[function]:
                continue
            dot_func = pydot.Cluster(g.cfg.vp.name[function],
                                     label=g.cfg.vp.name[function])
            dot_graph.add_subgraph(dot_func)
            for edge in function.out_edges():
                if g.cfg.ep.type[edge] != graph.CFType.f2a:
                    continue
                abb = edge.target()
                if g.cfg.vp.type[abb] == graph.ABBType.not_implemented:
                    assert not g.cfg.vp.implemented[function]
                    dot_abb = pydot.Node(str(hash(abb)),
                                         label="",
                                         shape="box")
                    dot_func.set('style', 'filled')
                    dot_func.set('color', '#eeeeee')
                else:
                    dot_abb = pydot.Node(
                        str(hash(abb)),
                        label=g.cfg.vp.name[abb],
                        shape=self.SHAPES[g.cfg.vp.type[abb]][0],
                        style=self.SHAPES[g.cfg.vp.type[abb]][1],
                        color=self.SHAPES[g.cfg.vp.type[abb]][2]
                    )
                dot_func.add_node(dot_abb)
        for edge in g.cfg.edges():
            if g.cfg.ep.type[edge] not in [graph.CFType.lcf, graph.CFType.icf]:
                continue
            color = "black"
            if g.cfg.ep.type[edge] == graph.CFType.lcf:
                color = "red"
            if g.cfg.ep.type[edge] == graph.CFType.icf:
                color = "blue"
            dot_graph.add_edge(pydot.Edge(str(hash(edge.source())),
                                          str(hash(edge.target())),
                                          color=color))
        dot_graph.write(dot)
        self._log.info(f"Write dot file to {dot}.")

    def run(self, g: graph.Graph):
        subgraph = self.subgraph.get()
        if subgraph == 'abbs':
            self.print_abbs(g)
