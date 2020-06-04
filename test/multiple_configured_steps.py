#!/usr/bin/env python3.6

import logging

from ara.stepmanager import StepManager, SolverException
from ara.graph import Graph
from native_step import Step
from ara.util import init_logging
from ara.steps.option import Option, String

shared_state = ""

class TestStep(Step):
    """Only for testing purposes"""
    def _fill_options(self):
        self.opt = Option(name="opt",
                          help="Just for testing",
                          step_name=self.get_name(),
                          ty=String())
        self.opts.append(self.opt)

    def run(self, graph: Graph):
        """Write unique string for testing."""
        opt = self.opt.get()
        global shared_state
        shared_state += f"Run: {self.get_name()}\n"
        if opt:
            shared_state += f"Opt: {opt}\n"


# Run 1 (valid):
# Test0 -> Test1 -> Test2 -> Special -> Test3 -> Special
#   ^        ^-------´ ^-----------------´ |
#   `--------------------------------------´

# Run 2 (invalid):
# Test0 -> Test1 -> Test3 -> Special -> Test2 -> Special
#   ^        ^       | `-----------------^ |
#   |        `-------+---------------------´
#   `----------------´


class Test0Step(TestStep):
    pass


class Test1Step(TestStep):
    pass


class Test2Step(TestStep):
    def get_dependencies(self):
        return ["Test1Step"]


class Test3Step(TestStep):
    def get_dependencies(self):
        return ["Test0Step", "Test2Step"]


class Special(TestStep):
    pass


def provide():
    yield Test0Step()
    yield Test1Step()
    yield Test2Step()
    yield Test3Step()
    yield Special()


trace = """
Run: Test1Step
Opt: defined
Run: Test0Step
Run: Test2Step
Run: Special
Opt: run1
Run: Test3Step
Run: Special
Opt: run2
"""[1:]


def main():
    init_logging(level=logging.DEBUG)
    g = Graph()
    config = {}
    p_manager = StepManager(g, provides=provide)

    extra_config = {"steps": ["Test2Step",
                              {"name": "Special", "opt": "run1"},
                              "Test3Step",
                              {"name": "Special", "opt": "run2"}],
                    "Test1Step": {"opt": "defined"}}

    global shared_state

    p_manager.execute(config, extra_config, None)
    assert(shared_state == trace)

    shared_state = ""
    config = {}
    extra_config = {"steps": ["Test3Step",
                              {"name": "Special", "opt": "run1"},
                              "Test2Step",
                              {"name": "Special", "opt": "run2"}],
                    "Test1Step": {"opt": "defined"}}

    try:
        p_manager.execute(config, extra_config, None)
    except SolverException as e:
        assert (str(e) ==
                "Test3Step depends on Test2Step but is scheduled after it")


if __name__ == '__main__':
    main()
