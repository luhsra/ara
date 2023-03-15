# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Common init function for tests."""
import importlib
import json
import sys
import os
import tempfile

from ara.os import get_os
from dataclasses import dataclass


def fake_step_module():
    """Fake the step module into the correct package."""
    sys.setdlopenflags(sys.getdlopenflags() | os.RTLD_GLOBAL)
    import graph_tool
    import pyllco
    def load(what, where):
        module = importlib.import_module(what)
        sys.modules[where] = module

    load("graph_data", "ara.graph.graph_data")
    load("py_logging", "ara.steps.py_logging")
    load("step", "ara.steps.step")

    sys.setdlopenflags(sys.getdlopenflags() & ~os.RTLD_GLOBAL)


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


def fail_if_json_not_equal(expected, actual):
    if expected != actual:
        def write_json_to_tmp(json_obj):
            path = ""
            with tempfile.NamedTemporaryFile(mode="w", delete=False) as f:
                path = f.name
                f.write(json.dumps(json_obj, indent=2))
            return path

        expected_path = write_json_to_tmp(expected)
        actual_path = write_json_to_tmp(actual)
        # run automatically diff to show difference in a convenient way
        os.system(f"echo \"diff <expected> <actual>:\"; diff {expected_path} {actual_path}")
        print("ERROR: Data not equal")
        os.unlink(expected_path)
        os.unlink(actual_path)
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


def init_test_logging(logger_name=None, log_level='warn'):
    # the environment is always more powerful
    log_level = os.environ.get('ARA_LOGLEVEL', log_level)
    logger = init_logging(level=log_level, root_name='ara.test')
    if logger_name is not None:
        logger = get_logger(logger_name)
    return logger


def init_test(steps=None, extra_config=None, logger_name=None,
              extra_input=None, os_name: str = "FreeRTOS"):
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
    os_name:      name of the os model to run the test with. If your test is
                  not sensitive to a specific os model just ignore this
                  argument.
    """
    log_level = os.environ.get('ARA_LOGLEVEL', 'warn')
    logger = init_test_logging(logger_name=logger_name)
    if not extra_config:
        extra_config = {}
    g = Graph()
    g.os = get_os(os_name)

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
