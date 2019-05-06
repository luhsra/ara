#!/usr/bin/env python3.6

import logging
import os.path

import stepmanager
import graph

from native_step import Step

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


TESTS = [('1.oil', validate_1)]

def main():
    s_dir = os.path.dirname(os.path.realpath(__file__))

    logging.basicConfig(level=logging.DEBUG)
    for oil, validate in TESTS:
        g = graph.PyGraph()
        config = {'oil': os.path.join(s_dir, oil), 'os': 'osek'}
        p_manager = stepmanager.StepManager(g, config)

        p_manager.execute(['OilStep'])

        validate(g)


if __name__ == '__main__':
    main()
