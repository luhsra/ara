#!/usr/bin/env python3.6
import graph
import stepmanager
import logging
import sys

from util import init_logging

from native_step import Step, provide_test_steps, provide_steps


def provide():
    """Provide all classes for the StepManager."""
    for step in provide_steps():
        yield step
    for step in provide_test_steps():
        yield step


def main():
    """Test for correct splitting of basic blocks."""
    init_logging(level=logging.DEBUG)
    g = graph.Graph()
    assert len(sys.argv) == 3
    test_step = sys.argv[1]
    i_file = sys.argv[2]
    config = {'log_level': 'debug',
              'dump_prefix': '/dev/null',
              'dump': False,
              'input_file': i_file}
    p_manager = stepmanager.StepManager(g, provides=provide)

    p_manager.execute(config, {}, [test_step])


if __name__ == '__main__':
    main()
