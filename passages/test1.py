import graph

from native_passage import Passage


class Test1Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return ["OilPassage"]

    def run(self, graph: graph.PyGraph):
        print("I'm an Test1Passage")
