#!/usr/bin/env python3
# vim: set et ts=4 sw=4:
"""Automated Realtime System Analysis"""

import argparse
import sys

import graph
import stepmanager


def print_avail_steps(avail_steps):
    """Return a nice formatted string with all available steps."""
    ret = "Available Steps:\n"
    ret += '\n'.join(['  ' + step for step in sorted(avail_steps)])
    return ret


def main():
    """Entry point for ARSA."""
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description=sys.modules[__name__].__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--verbose', '-v', help="be verbose",
                        action="store_true", default=False)
    parser.add_argument('--os', '-O', help="specify the operation system",
                        choices=['freertos', 'osek'], default='osek')
    parser.add_argument('--step', '-s', default=['DisplayResultsStep'],
                        help="choose steps that will be executed",
                        action='append')
    parser.add_argument('--list-steps', '-l', action="store_true",
                        default=False, help="list all available steps")
    parser.add_argument('input_files', help="all LLVM-IR input files",
                        nargs='?')

    args = parser.parse_args()

    g = graph.PyGraph()
    s_manager = stepmanager.StepManager(g, vars(args))
    avail_steps = s_manager.get_step_names()

    if args.list_steps:
        print(print_avail_steps(avail_steps))
        sys.exit(0)
    elif not args.input_files:
        parser.error('input_files are required (except -l or -h is set)')

    print("Processing files:", args.input_files[0])
    if len(set(args.step) & avail_steps) > 0:
        msg = 'Invalid step for --step. {}'.format(
            print_avail_steps(avail_steps))
        parser.error(msg)

    s_manager.execute(['DisplayResultsStep'])


if __name__ == '__main__':
    main()
