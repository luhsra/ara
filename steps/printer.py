"""Container for Printer."""
import graph

from native_step import Step, Option


class Printer(Step):
    """Print graphs to dot."""

    def config_help(self):
        return [Option(name="dot",
                       help="Path to a dot file, '-' will write to stdout."),
                Option(name="subgraph",
                       help=("Choose, what subgraph should be printed.\n"
                             "Possible values: 'abbs'")),
                Option(name="dump",
                       help="Dump graph to logger.")]

    def get_dependencies(self):
        return []

    def print_abbs(self):
        dump = self.get_config('dump')
        print(dump)

    def run(self, g: graph.PyGraph):
        subgraph = self.get_config('subgraph')
        if subgraph == 'abbs':
            self.print_abbs()
