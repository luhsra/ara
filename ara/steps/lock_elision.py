"""Container for Dummy."""
from ara.graph import Graph
from .step import Step
from .option import Option, Integer


class LockElision(Step):
    """Detect lock usages within the SSTG that are not necessary."""

    def get_single_dependencies(self):
        return ["MultiSSE"]

    def run(self):
        sstg = self._graph.reduced_sstg
        self._log.info("sstg")
