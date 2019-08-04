"""Container for Dummy."""
import graph

from native_step import Step
from .option import Option, Integer


class Dummy(Step):
    """Template for a new Python step."""

    def _fill_options(self):
        self.dummy_option = Option(name="dummy_option",
                                   help="An option to demonstrate options.",
                                   step_name=self.get_name(),
                                   ty=Integer())
        self.opts.append(self.dummy_option)

    def get_dependencies(self):
        return []

    def run(self, g: graph.PyGraph):
        self._log.info("Executing Dummy step.")
        opt, valid = self.dummy_option.get()
        if valid:
            self._log.info(f"Option is {opt}.")
