"""Container for Dummy."""
import graph

from native_step import Step, Option


class Dummy(Step):
    """Template for a new Python step."""

    def config_help(self):
        return [Option(name="dummy_option",
                       help="Just an option to demonstrate options.")]

    def get_dependencies(self):
        return []

    def run(self, g: graph.PyGraph):
        self._log.info("Executing Dummy step.")
