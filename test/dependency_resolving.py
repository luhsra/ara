#!/usr/bin/env python3.6

import passagemanager
import graph

from native_passage import Passage

shared_state = ""

class TestPassage(Passage):
    """Only for testing purposes"""

    def run(self, graph: graph.PyGraph):
        """Write unique string for testing."""
        global shared_state
        shared_state += f"Run: {self.get_name()}\n"


#  Test0  Test1  Test2  Test3
#    |  \   |  \           |
#    |   \  |   \_______   |
#    |    Test4         \  |
#    |      |            | |
#  Test5  Test6  Test7   | |
#      \    |    /       | |
#       \   |   /        | |
#         Test8         Test9


class Test0Passage(TestPassage):
    pass


class Test1Passage(TestPassage):
    pass


class Test2Passage(TestPassage):
    pass


class Test3Passage(TestPassage):
    pass


class Test4Passage(TestPassage):
    def get_dependencies(self):
        return ["Test0Passage", "Test1Passage"]


class Test5Passage(TestPassage):
    def get_dependencies(self):
        return ["Test0Passage"]


class Test6Passage(TestPassage):
    def get_dependencies(self):
        return ["Test4Passage"]


class Test7Passage(TestPassage):
    pass


class Test8Passage(TestPassage):
    def get_dependencies(self):
        return ["Test5Passage", "Test6Passage", "Test7Passage"]


class Test9Passage(TestPassage):
    def get_dependencies(self):
        return ["Test1Passage", "Test3Passage"]


# TestDep0
#    |
#    if (cond == True)
#    |
# TestDep1

class TestDep0(TestPassage):
    pass


class TestDep1(TestPassage):
    def get_dependencies(self):
        if self._config['cond']:
            return ["TestDep0"]
        return []


def provide(config):
    yield Test0Passage(config)
    yield Test1Passage(config)
    yield Test2Passage(config)
    yield Test3Passage(config)
    yield Test4Passage(config)
    yield Test5Passage(config)
    yield Test6Passage(config)
    yield Test7Passage(config)
    yield Test8Passage(config)
    yield Test9Passage(config)
    yield TestDep0(config)
    yield TestDep1(config)


tests = ["""
Run: Test1Passage
Run: Test0Passage
Run: Test4Passage
Run: Test7Passage
Run: Test6Passage
Run: Test5Passage
Run: Test8Passage
"""[1:], """
Run: Test3Passage
Run: Test1Passage
Run: Test9Passage
"""[1:], """
Run: Test1Passage
Run: Test0Passage
Run: Test4Passage
Run: Test3Passage
Run: Test7Passage
Run: Test6Passage
Run: Test5Passage
Run: Test9Passage
Run: Test8Passage
"""[1:]]


def main():
    g = graph.PyGraph()
    config = {}
    p_manager = passagemanager.PassageManager(g, config,
                                              provides=provide)

    global shared_state

    # standard tests
    p_manager.execute(['Test8Passage'])
    assert(shared_state == tests[0])
    shared_state = ""

    p_manager.execute(['Test9Passage'])
    assert(shared_state == tests[1])
    shared_state = ""

    p_manager.execute(['Test8Passage', 'Test9Passage'])
    assert(shared_state == tests[2])
    shared_state = ""

    # conditinal tests
    config['cond'] = False
    p_manager.execute(['TestDep1'])
    assert(shared_state == 'Run: TestDep1\n')
    shared_state = ""

    config['cond'] = True
    p_manager.execute(['TestDep1'])
    assert(shared_state == 'Run: TestDep0\nRun: TestDep1\n')
    shared_state = ""


if __name__ == '__main__':
    main()
