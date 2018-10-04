import graph

from .passage import Passage, And, Or


class Test3Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return Or("Test1Passage", "LLVMPassage")

    def run(self, graph: graph.PyGraph):
        print("I'm an Test3Passage")
