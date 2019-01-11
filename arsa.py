#!/usr/bin/env python3
# vim: set et ts=4 sw=4:

"""Automated Realtime System Analysis"""


import subprocess
import logging

import graph
#import pass1
import argparse
import sys
import stepmanager


from steps import OilStep


def main():
    """Entry point for ARSA."""

    parser = argparse.ArgumentParser(prog=sys.argv[0],
                                    description=sys.modules[__name__].__doc__)
    parser.add_argument('--verbose', '-v', help="be verbose",
                        action="store_true", default=False)
    parser.add_argument('--os', '-O', help="specify the operation system",
                        choices=['freertos', 'osek'], default='osek')
    parser.add_argument('input_files', help="all LLVM-IR input files",
                        nargs='+')

    args = parser.parse_args()

    g = graph.PyGraph()

    p_manager = stepmanager.StepManager(g, vars(args))

    p_manager.execute(['DisplayResultsStep'])


if __name__ == '__main__':
    main()
