#!/usr/bin/env python3.6
"""Checks the interoperability of Python and C++ passes."""

import passagemanager
import graph

from native_passage import Passage, provide_test_passages

# Test0Passage (C++)
#      |
# Test1Passage (Python)
#      |
# Test2Passage (C++)
#      |
# Test3Passage (Python)


class Test3Passage(Passage):
    def get_dependencies(self):
        return ["Test2Passage"]

    def run(self, graph: graph.PyGraph):
        print("Test3Passage")


class Test1Passage(Passage):
    def get_dependencies(self):
        return ["Test0Passage"]

    def run(self, graph: graph.PyGraph):
        print("Test1Passage")


def provide(config):
    """Provide all classes for the PassageManager."""
    for passage in provide_test_passages(config):
        yield passage
    yield Test1Passage(config)
    yield Test3Passage(config)


def main():
    """Checks the interoperability of Python and C++ passes."""
    g = graph.PyGraph()
    config = {}
    p_manager = passagemanager.PassageManager(g, config,
                                              provides=provide)

    p_manager.execute(['Test3Passage'])


if __name__ == '__main__':
    main()
