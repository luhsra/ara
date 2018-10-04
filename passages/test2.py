import graph

from .passage import Passage, And


class Test2Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return And("OilPassage", "Test1Passage")

    def run(self, graph: graph.PyGraph):
        print("I'm an Test2Passage")
