#!/usr/bin/env python3.6
"""Checks the interoperability of Python and C++ passes."""

import stepmanager
import graph
import logging

from native_step import Step, provide_test_steps

# Test0Step (C++)
#      |
# Test1Step (Python)
#      |
# Test2Step (C++)
#      |
# Test3Step (Python)


class Test3Step(Step):
    def get_dependencies(self):
        return ["Test2Step"]

    def run(self, graph: graph.PyGraph):
        log = logging.getLogger(self.__class__.__name__)
        log.info("Running...")


class Test1Step(Step):
    def get_dependencies(self):
        return ["Test0Step"]

    def run(self, graph: graph.PyGraph):
        log = logging.getLogger(self.__class__.__name__)
        log.info("Running...")


def provide(config):
    """Provide all classes for the StepManager."""
    for step in provide_test_steps(config):
        yield step
    yield Test1Step(config)
    yield Test3Step(config)


def main():
    """Checks the interoperability of Python and C++ passes."""
    g = graph.PyGraph()
    config = {}
    p_manager = stepmanager.StepManager(g, config,
                                              provides=provide)

    p_manager.execute(['Test3Step'])


if __name__ == '__main__':
    main()
