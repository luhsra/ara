#!/usr/bin/env python3.6

# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import logging

from init_test import get_config

from ara import stepmanager
from ara import graph

from step import Step
from ara.util import init_logging
from ara.steps.option import Option, Bool

class TestStep(Step):
    """Only for testing purposes"""
    def run(self):
        pass


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
    def get_single_dependencies(self):
        return ["Test0Step", "Test1Step"]


class Test5Step(TestStep):
    def get_single_dependencies(self):
        return ["Test0Step"]


class Test6Step(TestStep):
    def get_single_dependencies(self):
        return ["Test4Step"]


class Test7Step(TestStep):
    pass


class Test8Step(TestStep):
    def get_single_dependencies(self):
        return ["Test5Step", "Test6Step", "Test7Step"]


class Test9Step(TestStep):
    def get_single_dependencies(self):
        return ["Test1Step", "Test3Step"]


# TestDep0
#    |
#    if (cond == True)
#    |
# TestDep1

class TestDep0(TestStep):
    pass


class TestDep1(TestStep):
    cond = Option(name="cond",
                  help="Testopt",
                  ty=Bool())

    def get_single_dependencies(self):
        print(self.cond.get())
        if self.cond.get():
            return ["TestDep0"]
        return []


# TestDep0(cond=X)
#    |
# TestDep1(cond=X)

class TestCond0(TestStep):
    cond = Option(name="cond",
                  help="Testopt",
                  ty=Bool())


class TestCond1(TestStep):
    cond = Option(name="cond",
                  help="Testopt",
                  ty=Bool())

    def get_single_dependencies(self):
        return [{"name": "TestCond0",
                 "cond": self.cond.get()}]

# TestChain0
#     |   |
#     |   |--triggers first--TestChain1
#     |   |
#     |   |                 TestChain2
#     |-depends on                |
#     |   |                       |-depends on
#     |   |                       |
#     |    --triggers then--TestChain3
#     |
# TestChain4


class TestChain0(TestStep):
    def run(self):
        self._step_manager.chain_step({"name": "TestChain3"})
        self._step_manager.chain_step({"name": "TestChain1"})


class TestChain1(TestStep):
    pass


class TestChain2(TestStep):
    pass


class TestChain3(TestStep):
    def get_single_dependencies(self):
        return ["TestChain2"]


class TestChain4(TestStep):
    def get_single_dependencies(self):
        return ["TestChain0"]


# TestConfig0 (changes config)
#     |
#     | depends on
#     |
# TestConfig1

class TestConfig0(TestStep):
    def run(self):
        self._step_manager.change_global_config({"dump": True})

class TestConfig1(TestStep):
    def get_single_dependencies(self):
        return ["TestConfig0"]


def provide():
    yield Test0Step
    yield Test1Step
    yield Test2Step
    yield Test3Step
    yield Test4Step
    yield Test5Step
    yield Test6Step
    yield Test7Step
    yield Test8Step
    yield Test9Step

    yield TestDep0
    yield TestDep1

    yield TestCond0
    yield TestCond1

    yield TestChain0
    yield TestChain1
    yield TestChain2
    yield TestChain3
    yield TestChain4

    yield TestConfig0
    yield TestConfig1


TESTS = [
    [
        'Test0Step',
        'Test5Step',
        'Test1Step',
        'Test4Step',
        'Test6Step',
        'Test7Step',
        'Test8Step'
    ], [
        'Test1Step',
        'Test3Step',
        'Test9Step'
    ], [
        'Test0Step',
        'Test5Step',
        'Test1Step',
        'Test4Step',
        'Test6Step',
        'Test7Step',
        'Test8Step',
        'Test3Step',
        'Test9Step'
    ], [
        ('TestCond0', True),
        ('TestCond0', False),
        ('TestCond1', False)
    ], [
        'TestChain0',
        'TestChain1',
        'TestChain2',
        'TestChain3',
        'TestChain4'
    ], [
        ('TestConfig0', False),
        ('TestConfig1', True),
    ]
]

def main():
    init_logging(level=logging.DEBUG)
    g = graph.Graph()
    config = get_config('/dev/null')
    extra_config = {}
    p_manager = stepmanager.StepManager(g, provides=provide)

    # standard tests
    p_manager.clear_history()
    p_manager.execute(config, extra_config, ['Test8Step'])
    assert TESTS[0] == [x.name for x in p_manager.get_history()]

    p_manager.clear_history()
    p_manager.execute(config, extra_config, ['Test9Step'])
    assert TESTS[1] == [x.name for x in p_manager.get_history()]

    p_manager.clear_history()
    p_manager.execute(config, extra_config, ['Test8Step', 'Test9Step'])
    assert TESTS[2] == [x.name for x in p_manager.get_history()]

    # conditional dependencies
    config['cond'] = False
    p_manager.clear_history()
    p_manager.execute(config, extra_config, ['TestDep1'])
    assert [x.name for x in p_manager.get_history()] == ['TestDep1']

    config['cond'] = True
    p_manager.clear_history()
    p_manager.execute(config, extra_config, ['TestDep1'])
    assert [x.name for x in p_manager.get_history()] == ['TestDep0', 'TestDep1']

    # dependencies to conditionals
    config['cond'] = False
    extra_config2 = {"TestCond0": {'cond': True}}
    p_manager.clear_history()
    p_manager.execute(config, extra_config2, ['TestCond0', 'TestCond1'])
    assert TESTS[3] == [(x.name, x.all_config['cond'])
                        for x in p_manager.get_history()]

    # chain step
    p_manager.clear_history()
    p_manager.execute(config, extra_config, ['TestChain4'])
    assert TESTS[4] == [x.name for x in p_manager.get_history()]

    # global config test
    config2 = get_config('/dev/null')
    config2["dump"] = False
    p_manager.clear_history()
    p_manager.execute(config2, extra_config, ['TestConfig1'])
    assert TESTS[5] == [(x.name, x.all_config['dump'])
                        for x in p_manager.get_history()]


if __name__ == '__main__':
    main()
