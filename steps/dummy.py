"""Container for Dummy."""
import graph

from native_step import Step


class Dummy(Step):
    """Template for a new Python step."""

    def get_dependencies(self):
        return []

    def run(self, g: graph.PyGraph):
        self._log.info("Executing Dummy step.")
