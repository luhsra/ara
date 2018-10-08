import graph

from native_passage import Passage


class OilPassage(Passage):
    """Reads an oil file and writes all information to the graph."""

    def run(self, graph: graph.PyGraph):
        print("I'm an OilPassage")
