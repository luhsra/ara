from ara.graph import Graph
from .step import Step

class MultiSSE(Step):
    """
    Runs the MultiCore SSE.
    """
    def get_dependencies(self):
        return ["Syscall", "LoadOIL"]
    
    def _fill_options(self):
        pass

    def run(self, g: Graph):
        self._log.info("Executing MultiSSE step.")