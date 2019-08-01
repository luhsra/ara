"""Container for Dummy."""
import graph

from native_step import Step
from .option import Option, Integer


class Dummy(Step):
    """Template for a new Python step."""

    def options(self):
        return [Option(name="dummy_option",
                       help="Just an option to demonstrate options.",
                       step_name=self.get_name(),
                       ty=Integer())]

    def get_dependencies(self):
        return []

    def run(self, g: graph.PyGraph):
        self._log.info("Executing Dummy step.")
