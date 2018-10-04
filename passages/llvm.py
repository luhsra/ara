import graph

from .passage import Passage, And


class LLVMPassage(Passage):
    """Converts an IR file into LLVM datastructures and fill the graph."""

    def get_dependencies(self):
        if self._config.os == 'osek':
            return And("OilPassage")
        return []


    def run(self, graph: graph.PyGraph):
        print("I'm an LLVMPassage")
