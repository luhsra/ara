"""Container for Printer."""
import graph
from .option import Option, String, Choice, Bool

from native_step import Step


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
        self.opts += [self.dot, self.dump, self.subgraph]

    def print_abbs(self, graph):
        dump, valid = self.dump.get()
        if valid and dump:
            print(graph.new_graph.abbs())

    def run(self, g: graph.PyGraph):
        subgraph, valid = self.subgraph.get()
        if valid and subgraph == 'abbs':
            self.print_abbs(g)
