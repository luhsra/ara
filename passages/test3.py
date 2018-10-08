import graph

from native_passage import Passage


class Test3Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return ["Test1Passage", "LLVMPassage"]

    def run(self, graph: graph.PyGraph):
        print("I'm an Test3Passage")
