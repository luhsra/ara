#!/usr/bin/env python3
"""Checks the interoperability of Python and C++ passes."""
if __name__ == '__main__':
    __package__ = 'test.native_step_test'

from ..init_test import get_config

from ara.stepmanager import StepManager
from ara.graph import Graph
from ara.steps.step import Step, provide_test_steps

# Test0Step (C++)
#      |
# Test1Step (Python)
#      |
# Test2Step (C++)
#      |
# Test3Step (Python)


class Test3Step(Step):
    def get_single_dependencies(self):
        return ["Test2Step"]

    def run(self):
        self._log.info("Running...")


class Test1Step(Step):
    def get_single_dependencies(self):
        return ["Test0Step"]

    def run(self):
        self._log.info("Running...")


def provide():
    """Provide all classes for the StepManager."""
    for step in provide_test_steps():
        yield step
    yield Test1Step
    yield Test3Step


def main():
    """Checks the interoperability of Python and C++ passes."""
    graph = Graph()
    config = get_config('/dev/null')
    extra_config = {}
    p_manager = StepManager(graph, provides=provide)

    p_manager.execute(config, extra_config, ['Test3Step'])
    assert [step.name for step in p_manager.get_history()] == ['Test0Step',
                                                               'Test1Step',
                                                               'Test2Step',
                                                               'Test3Step']


if __name__ == '__main__':
    main()
