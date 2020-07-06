"""Container for Dummy."""
from ara.graph import Graph
from .step import Step
from .option import Option, Integer


class Dummy(Step):
    """Template for a new Python step."""
    dummy_option = Option(name="dummy_option",
                          help="An option to demonstrate options.",
                          ty=Integer())

    def get_dependencies(self, _):
        return []

    def run(self):
        self._log.info("Executing Dummy step.")
        opt = self.dummy_option.get()
        if opt:
            self._log.info(f"Option is {opt}.")
