#!/usr/bin/env python3.6
import graph
import stepmanager
import logging
import sys

from util import init_logging

from native_step import Step, provide_test_steps, provide_steps


def provide(config):
    """Provide all classes for the StepManager."""
    for step in provide_steps(config):
        yield step
    for step in provide_test_steps(config):
        yield step


def main():
    """Test for correct splitting of basic blocks."""
    init_logging(level=logging.DEBUG)
    g = graph.PyGraph()
    os_name = sys.argv[1]
    test_step = sys.argv[2]
    i_files = sys.argv[3:]
    config = {'os': os_name,
              'input_files': i_files}
    p_manager = stepmanager.StepManager(g, config,
                                        provides=provide)

    p_manager.execute([test_step])


if __name__ == '__main__':
    main()
