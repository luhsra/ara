import passages
import graph

from typing import List


class PassageManager:
    """Manages all passages."""
    _passages = {}
    _graph = None

    def __init__(self, g: graph.PyGraph):
        self._graph = g

    def register(self, passage: passages.Passage):
        """Register a passage."""
        self._passages[passage.get_name()] = passage

    def execute(self, passes: List[str]):
        """Executes all passages in correct order.

        Arguments:
            passes -- list of passes to execute
        """
        # TODO transform this into a graph data structure
        # this is really quick and dirty
        for passage in passes:
            for dep in self._passages[passage].get_dependencies():
                print(passage, dep)
                passes.append(dep)
        print(passes)

        executed = set()
        for passage in reversed(passes):
            if passage not in executed:
                self._passages[passage].run(self._graph)
                executed.add(passage)
