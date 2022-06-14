"""Common init function for tests."""
import importlib
import json
import logging
import sys
import os

from dataclasses import dataclass


def fake_step_module():
    """Fake the step module into the correct package."""
    import graph_tool
    def load(what, where):
        module = importlib.import_module(what)
        sys.modules[where] = module

    load("graph_data", "ara.graph.graph_data")
    load("py_logging", "ara.steps.py_logging")
    load("step", "ara.steps.step")


fake_step_module()


# this imports has to be _below_ the call to fake_step_module
from ara.util import init_logging, get_logger
from ara.graph import Graph
from ara.stepmanager import StepManager


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
        print("Tracefile:", sys.argv[1], file=sys.stderr)
        if condition and not dry:
            sys.exit(1)


def get_config(i_file):
    """Return the default common config."""
    return {'log_level': os.environ.get('ARA_LOGLEVEL', 'warn'),
            'dump_prefix': 'dumps/{step_name}',
            'dump': bool(os.environ.get('ARA_DUMP', '')),
            'runtime_stats': True,
            'runtime_stats_file': 'logger',
            'runtime_stats_format': 'human',
            'entry_point': 'main',
            'step_data': False,
            'input_file': i_file}


@dataclass
class TestData:
    graph: Graph
    data: dict
    data_file: str
    log: object
    step_manager: StepManager


def init_test(steps=None, extra_config=None, logger_name=None,
              extra_input=None):
    """Common interface for test. Reads a JSON file and some ll-file from the
    command line and make them available.

    CLI usage when using init_test:
    your_program <os_name> <json_file> <ll_files>

    Return a graph reference, the JSON struct and the stepmanager instance.

    Arguments:
    steps:        List of steps, see the `esteps` argument of
                  Stepmanager.execute.
    extra_config: Dict with extra configuration, see the `extra_config`
                  argument of Stepmanager.execute.
    logger_name:  Create a logger with this name. Otherwise the root logger is
                  returned.
    extra_input:  Special dict which can be used to do extra stuff with input
                  arguments.  Expected is a [str: function]
                  The str becomes to a normal ARA config string, the function
                  gets sys.argv as argument and should return a valid value.
    """
    log_level = os.environ.get('ARA_LOGLEVEL', 'warn')
    logger = init_logging(level=log_level, root_name='ara.test')
    if logger_name is not None:
        logger = get_logger(logger_name)
    if not extra_config:
        extra_config = {}
    g = Graph()

    json_file = sys.argv[1]
    i_file = sys.argv[2]

    if not extra_input:
        extra_input = {}
    for key in extra_input:
        extra_input[key] = extra_input[key](sys.argv)

    logger.info(f"Testing with JSON: '{json_file}'"
                f", and file: {i_file}")
    if steps:
        logger.info(f"Executing steps: {steps}")
    elif extra_config:
        logger.info(f"Executing with config: {extra_config}")
    else:
        assert False
    conf = {**get_config(i_file), **extra_input}
    logger.debug(f"Full config: {conf}")
    with open(json_file) as f:
        data = json.load(f)

    s_manager = StepManager(g)

    s_manager.execute(conf, extra_config, steps)

    return TestData(graph=g,
                    data=data,
                    data_file=json_file,
                    log=logger,
                    step_manager=s_manager)
