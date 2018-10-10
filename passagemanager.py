import passages
import graph

from typing import List


class PassageManager:
    """Manages all passages.

    Knows about all passages and can execute them in correct order.
    Usage: Construct one instance of PassageManager and then call execute()
    with a list of passage that should be executed.
    """

    def __init__(self, g: graph.PyGraph, config: dict,
                 provides=passages.provide_passages):
        """Construct a PassageManager.

        Arguments:
        g      -- the system graph
        config -- the program configuration. This should be a dict.

        Keyword arguments:
        provides -- An optional provides function to announce the passes to
                    PassageManager
        """
        self._graph = g
        self._config = config
        self._passages = {}
        for passage in provides(config):
            self._passages[passage.get_name()] = passage

    def execute(self, passages: List[str]):
        """Executes all passages in correct order.

        Arguments:
        passages -- list of passsages to execute. The elements are strings that
                    matches the ones returned by passage.get_name().
        """
        # TODO transform this into a graph data structure
        # this is really quick and dirty
        for passage in passages:
            for dep in self._passages[passage].get_dependencies():
                passages.append(dep)

        executed = set()
        for passage in reversed(passages):
            if passage not in executed:
                self._passages[passage].run(self._graph)
                executed.add(passage)
