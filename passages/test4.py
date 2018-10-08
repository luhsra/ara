import graph

from native_passage import Passage


class Test4Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return ["Test3Passage"]

    def run(self, graph: graph.PyGraph):
        print("I'm an Test4Passage")
