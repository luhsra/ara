#!/usr/bin/env python3.6

import stepmanager
import graph

from native_step import Step

shared_state = ""

class TestStep(Step):
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


class Test0Step(TestStep):
    pass


class Test1Step(TestStep):
    pass


class Test2Step(TestStep):
    pass


class Test3Step(TestStep):
    pass


class Test4Step(TestStep):
    def get_dependencies(self):
        return ["Test0Step", "Test1Step"]


class Test5Step(TestStep):
    def get_dependencies(self):
        return ["Test0Step"]


class Test6Step(TestStep):
    def get_dependencies(self):
        return ["Test4Step"]


class Test7Step(TestStep):
    pass


class Test8Step(TestStep):
    def get_dependencies(self):
        return ["Test5Step", "Test6Step", "Test7Step"]


class Test9Step(TestStep):
    def get_dependencies(self):
        return ["Test1Step", "Test3Step"]


# TestDep0
#    |
#    if (cond == True)
#    |
# TestDep1

class TestDep0(TestStep):
    pass


class TestDep1(TestStep):
    def get_dependencies(self):
        if self._config['cond']:
            return ["TestDep0"]
        return []


def provide(config):
    yield Test0Step(config)
    yield Test1Step(config)
    yield Test2Step(config)
    yield Test3Step(config)
    yield Test4Step(config)
    yield Test5Step(config)
    yield Test6Step(config)
    yield Test7Step(config)
    yield Test8Step(config)
    yield Test9Step(config)
    yield TestDep0(config)
    yield TestDep1(config)


tests = ["""
Run: Test1Step
Run: Test0Step
Run: Test4Step
Run: Test7Step
Run: Test6Step
Run: Test5Step
Run: Test8Step
"""[1:], """
Run: Test3Step
Run: Test1Step
Run: Test9Step
"""[1:], """
Run: Test1Step
Run: Test0Step
Run: Test4Step
Run: Test3Step
Run: Test7Step
Run: Test6Step
Run: Test5Step
Run: Test9Step
Run: Test8Step
"""[1:]]


def main():
    g = graph.PyGraph()
    config = {}
    p_manager = stepmanager.StepManager(g, config,
                                              provides=provide)

    global shared_state

    # standard tests
    p_manager.execute(['Test8Step'])
    assert(shared_state == tests[0])
    shared_state = ""

    p_manager.execute(['Test9Step'])
    assert(shared_state == tests[1])
    shared_state = ""

    p_manager.execute(['Test8Step', 'Test9Step'])
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
