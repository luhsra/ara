import graph

from .passage import Passage, And


class Test4Passage(Passage):
    """Only for testing purposes"""

    def get_dependencies(self):
        return And("Test3Passage")

    def run(self, graph: graph.PyGraph):
        print("I'm an Test4Passage")
