"""Container for Printer."""
import graph
from .option import Option, String, Choice, Bool

from native_step import Step

import pydot


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
        self.dump = Option(name="dump",
                           help="Dump graph to logger.",
                           step_name=self.get_name(),
                           ty=Bool())
        self.subgraph = Option(name="subgraph",
                               help="Choose, what subgraph should be printed.",
                               step_name=self.get_name(),
                               ty=Choice("abbs"))
        self.opts += [self.dot, self.graph_name, self.dump, self.subgraph]

    def print_abbs(self, g):
        abbs = g.new_graph.abbs()

        if self.dump.get():
            for line in str(abbs).splitlines():
                self._log.info(line)
        dot = self.dot.get()
        if not dot:
            return
        name = self.graph_name.get()
        if not name:
            name = ''
        dot_graph = pydot.Dot(graph_type='digraph', label=name)
        for function in abbs.functions():
            dot_func = pydot.Cluster(function.name, label=function.name)
            dot_graph.add_subgraph(dot_func)
            for abb in function.vertices():
                abb = function.local_to_global(abb)
                if abb.type == graph.ABBType.not_implemented:
                    assert not function.implemented
                    dot_abb = pydot.Node(str(hash(abb)),
                                         label="",
                                         shape="box")
                    dot_func.set('style', 'filled')
                    dot_func.set('color', '#eeeeee')
                else:
                    dot_abb = pydot.Node(str(hash(abb)),
                                         label=abb.name,
                                         shape=self.SHAPES[abb.type][0],
                                         style=self.SHAPES[abb.type][1],
                                         color=self.SHAPES[abb.type][2])
                dot_func.add_node(dot_abb)
        for edge in abbs.edges():
            color = "black"
            if edge.type == graph.CFType.lcf:
                color = "red"
            if edge.type == graph.CFType.icf:
                color = "blue"
            dot_graph.add_edge(pydot.Edge(str(hash(edge.source())),
                                          str(hash(edge.target())),
                                          color=color))
        dot_graph.write(dot)
        self._log.info(f"Write dot file to {dot}.")

    def run(self, g: graph.PyGraph):
        subgraph = self.subgraph.get()
        if subgraph == 'abbs':
            self.print_abbs(g)
