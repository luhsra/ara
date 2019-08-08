"""Container for Printer."""
import graph
from .option import Option, String, Choice, Bool

from native_step import Step

import pydot


class Printer(Step):
    """Print graphs to dot."""

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

    def print_abbs(self, graph):
        abbs = graph.new_graph.abbs()

        dump, valid = self.dump.get()
        if valid and dump:
            for line in str(abbs).splitlines():
                self._log.info(line)
        dot, valid = self.dot.get()
        if not valid:
            return
        name, valid = self.graph_name.get()
        print(name, valid)
        if not valid:
            name = ''
        graph = pydot.Dot(graph_type='digraph', label=name)
        empty_count = 0
        for function in abbs.functions():
            dot_func = pydot.Cluster(function.name, label=function.name)
            graph.add_subgraph(dot_func)
            abb = None
            for abb in function.vertices():
                dot_abb = pydot.Node(str(abb.graph_id), label=abb.name)
                dot_func.add_node(dot_abb)
            if not abb:
                dot_func.set('style', 'filled')
                dot_func.set('color', '#eeeeee')
                dot_func.add_node(pydot.Node("empty-" + str(empty_count),
                                             label="",
                                             shape="none"))
                empty_count += 1

        for edge in abbs.edges():
            graph.add_edge(pydot.Edge(str(edge.source().graph_id),
                                      str(edge.target().graph_id)))
        graph.write(dot)
        self._log.info(f"Write dot file to {dot}.")

    def run(self, g: graph.PyGraph):
        subgraph, valid = self.subgraph.get()
        if valid and subgraph == 'abbs':
            self.print_abbs(g)
