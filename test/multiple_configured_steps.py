#!/usr/bin/env python3.6

# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""
Test double execution of steps if the dependencies cannot be solved in a
way, where each step is executed once.
"""

from init_test import get_config

import logging

from ara.stepmanager import StepManager
from ara.graph import Graph
from ara.steps.step import Step
from ara.steps.option import Option, String
from ara.util import init_logging

class TestStep(Step):
    """Only for testing purposes"""
    opt = Option(name="opt",
                 help="Just for testing",
                 ty=String())

    def run(self):
        pass


# Run 1 (valid):
# Test1 -> Test2 -> Special -> Test0 -> Test3 -> Special
#   ^        ^-------------------^-------´ |
#   `--------------------------------------´

# Run 2 (double execution of Test2):
# Test0 -> Test1 -> Test3 -> Special -> Test2 -> Special
#   ^        ^       | `-----------------^ |
#   |        `-------+---------------------´
#   `----------------´
# Text0 -> Test1 -> Test2 -> Test3 -> Special -> Test2 -> Special


class Test0Step(TestStep):
    pass


class Test1Step(TestStep):
    pass


class Test2Step(TestStep):
    def get_single_dependencies(self):
        return ["Test1Step"]


class Test3Step(TestStep):
    def get_single_dependencies(self):
        return ["Test0Step", "Test2Step"]


class Special(TestStep):
    pass


def provide():
    yield Test0Step
    yield Test1Step
    yield Test2Step
    yield Test3Step
    yield Special


TRACE = [
    [
        ('Test1Step', 'defined'),
        ('Test2Step', None),
        ('Special', 'run1'),
        ('Test0Step', None),
        ('Test3Step', None),
        ('Special', 'run2')
    ], [
        ('Test0Step', None),
        ('Test1Step', 'defined'),
        ('Test2Step', None),
        ('Test3Step', None),
        ('Special', 'run1'),
        ('Test2Step', None),
        ('Special', 'run2')
    ]
]


def main():
    init_logging(level=logging.DEBUG)
    g = Graph()
    config = get_config('/dev/null')
    p_manager = StepManager(g, provides=provide)

    extra_config = {"steps": ["Test2Step",
                              {"name": "Special", "opt": "run1"},
                              "Test3Step",
                              {"name": "Special", "opt": "run2"}],
                    "Test1Step": {"opt": "defined"}}

    p_manager.clear_history()
    p_manager.execute(config, extra_config, None)
    hist = [(step.name, step.all_config.get("opt", None))
            for step in p_manager.get_history()]
    assert hist == TRACE[0]

    config = get_config('/dev/null')
    extra_config = {"steps": ["Test3Step",
                              {"name": "Special", "opt": "run1"},
                              "Test2Step",
                              {"name": "Special", "opt": "run2"}],
                    "Test1Step": {"opt": "defined"}}

    p_manager.clear_history()
    p_manager.execute(config, extra_config, None)
    hist = [(step.name, step.all_config.get("opt", None))
            for step in p_manager.get_history()]
    assert hist == TRACE[1]


if __name__ == '__main__':
    main()
