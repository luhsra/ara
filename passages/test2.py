import graph

from native_passage import Passage


class Test2Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return ["OilPassage", "Test1Passage"]

    def run(self, graph: graph.PyGraph):
        print("I'm an Test2Passage")
