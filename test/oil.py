#!/usr/bin/env python3.6

import init_test


import logging
import os.path
import sys

from ara.stepmanager import StepManager
from ara.graph import Graph
from ara.util import init_logging

from ara.steps.step import Step

TASKS_1 = {
    'Handler11': {
        "schedule": True,
        "priority": 4,
        "activation": 1,
        "autostart": True
    },
    "Handler12": {
        "schedule": True,
        "priority": 3,
        "activation": 1,
        "autostart": False
    },
    "Handler13": {
        "schedule": True,
        "priority": 5,
        "activation": 1,
        "autostart": False
    }}


def validate_1(g):
    """Validate 1.oil."""
    tasks = g.get_type_vertices('Task')

    for t in tasks:
        assert t.get_name() in TASKS_1
        task = TASKS_1[t.get_name()]
        assert t.is_scheduled() == task['schedule']
        assert t.get_priority() == task['priority']
        assert t.is_autostarted() == task['autostart']
        assert t.get_activation() == task['activation']


TESTS = [(sys.argv[1], sys.argv[2], validate_1)]


def main():
    init_logging(level=logging.DEBUG, max_stepname=len("StepManager"))

    for file, oil, validate in TESTS:
        g = Graph()
        config = {'oilfile': oil,
                  'os': 'OSEK',
                  'input_files': [file]}
        extra_config = {}
        p_manager = StepManager(g)

        p_manager.execute(config, extra_config, ['OilStep'])

        validate(g)


if __name__ == '__main__':
    # skip for now, until we have an AUTOSAR/OSEK detection again
    sys.exit(77)
    main()
