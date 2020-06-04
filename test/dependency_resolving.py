#!/usr/bin/env python3.6

import logging

# only importing is relevant. This module is not used otherwise.
import init_test

from ara import stepmanager
from ara import graph

from step import Step
from ara.util import init_logging
from ara.steps.option import Option, Bool

shared_state = ""

class TestStep(Step):
    """Only for testing purposes"""

    def run(self, graph: graph.Graph):
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
    def _fill_options(self):
        self.cond = Option(name="cond",
                           help="Testopt",
                           step_name=self.get_name(),
                           ty=Bool())
        self.opts.append(self.cond)

    def get_dependencies(self):
        print(self.cond.get())
        if self.cond.get():
            return ["TestDep0"]
        return []


def provide():
    yield Test0Step()
    yield Test1Step()
    yield Test2Step()
    yield Test3Step()
    yield Test4Step()
    yield Test5Step()
    yield Test6Step()
    yield Test7Step()
    yield Test8Step()
    yield Test9Step()
    yield TestDep0()
    yield TestDep1()


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
Run: Test7Step
Run: Test6Step
Run: Test5Step
Run: Test3Step
Run: Test8Step
Run: Test9Step
"""[1:]]


def main():
    init_logging(level=logging.DEBUG)
    g = graph.Graph()
    config = {}
    extra_config = {}
    p_manager = stepmanager.StepManager(g, provides=provide)

    global shared_state

    # standard tests
    p_manager.execute(config, extra_config, ['Test8Step'])
    assert(shared_state == tests[0])
    shared_state = ""

    p_manager.execute(config, extra_config, ['Test9Step'])
    assert(shared_state == tests[1])
    shared_state = ""

    p_manager.execute(config, extra_config, ['Test8Step', 'Test9Step'])
    assert(shared_state == tests[2])
    shared_state = ""

    # conditional tests
    config['cond'] = False
    p_manager.execute(config, extra_config, ['TestDep1'])
    assert(shared_state == 'Run: TestDep1\n')
    shared_state = ""

    config['cond'] = True
    p_manager.execute(config, extra_config, ['TestDep1'])
    assert(shared_state == 'Run: TestDep0\nRun: TestDep1\n')
    shared_state = ""


if __name__ == '__main__':
    main()
