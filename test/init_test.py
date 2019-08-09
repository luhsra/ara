"""Common init function for tests."""
import sys
import json
import logging

from util import init_logging

import graph
import stepmanager


def fail_with(*arg):
    """Print an error message and exit."""
    print("ERROR:", *arg, file=sys.stderr)
    sys.exit(1)


def fail_if(condition, *arg, dry=False):
    """Exit with error message, if condition is met.

    Keyword argument:
    dry -- Don't check and fail, only print message
    """
    if condition or dry:
        print("ERROR:", *arg, file=sys.stderr)
        if condition and not dry:
            sys.exit(1)


def init_test(steps=None, extra_config=None):
    """CLI usage: your_program <os_name> <json_file> <ll_files>"""
    init_logging(level=logging.DEBUG)
    if steps is None:
        steps = ['ValidationStep']
    if not extra_config:
        extra_config = {}
    g = graph.PyGraph()
    os_name = sys.argv[1]
    json_file = sys.argv[2]
    i_files = sys.argv[3:]
    print(f"Testing with JSON: '{json_file}', OS: '{os_name}'" +
          f", and files: {i_files}")
    print(f"Executing steps: {steps}")
    with open(json_file) as f:
        data = json.load(f)

    s_manager = stepmanager.StepManager(g)

    config = {'os': os_name,
              'log_level': 'debug',
              'input_files': i_files}
    s_manager.execute(config, extra_config, steps)

    return g, data, s_manager
