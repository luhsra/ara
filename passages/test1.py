import graph

from .passage import Passage, And


class Test1Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return And("OilPassage")

    def run(self, graph: graph.PyGraph):
        print("I'm an Test1Passage")
