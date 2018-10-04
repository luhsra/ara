import passages
import graph


class PassageManager:
    """Manages all passages."""
    _passages = {}
    _graph = None

    def __init__(self, g: graph.PyGraph):
        self._graph = g

    def register(self, passage: passages.Passage):
        """Register a passage."""
        self._passages[passage.get_name()] = passage

    def execute(self):
        """Executes all passages in correct order."""
        # TODO transform this into a graph data structure
        # this is really quick and dirty
        passes = set(self._passages.keys())
        for passage in self._passages.values():
            for dep in passage.get_dependencies():
                try:
                    print(dep, passes)
                    passes.remove(dep)
                except ValueError:
                    pass
        assert(len(passes) > 0)
        passes = list(passes)
        for passage in passes:
            for dep in self._passages[passage].get_dependencies():
                passes.append(dep)
        print(passes)

        executed = set()
        for passage in reversed(passes):
            if passage not in executed:
                self._passages[passage].run(self._graph)
                executed.add(passage)
