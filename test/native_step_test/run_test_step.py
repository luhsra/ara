#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

if __name__ == '__main__':
    __package__ = 'test.native_step_test'

import logging
import sys

from ..init_test import get_config

from ara.util import init_logging
from ara.graph import Graph
from ara.stepmanager import StepManager
from ara.steps.step import provide_test_steps
from ara.steps import provide_steps
from ara.os import get_os



def provide():
    """Provide all classes for the StepManager."""
    for step in provide_steps():
        yield step
    for step in provide_test_steps():
        yield step


def main():
    """Test for correct splitting of basic blocks."""
    init_logging(level=logging.DEBUG)
    g = Graph()
    g.os = get_os("FreeRTOS")
    assert len(sys.argv) == 3
    test_step = sys.argv[1]
    i_file = sys.argv[2]
    p_manager = StepManager(g, provides=provide)

    p_manager.execute(get_config(i_file), {}, [test_step])


if __name__ == '__main__':
    main()
