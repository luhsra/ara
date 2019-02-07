#!/usr/bin/env python3
# vim: set et ts=4 sw=4:
"""Automated Realtime System Analysis"""

import argparse
import sys
import shutil
import textwrap

import graph
import stepmanager


def print_avail_steps(avail_steps):
    """Return a nice formatted string with all available steps."""
    indent = 2
    ret = "Available Steps:\n"
    steps = sorted([(x.get_name(), x.get_description()) for x in avail_steps])
    max_len = max([len(x[0]) for x in steps])

    term_width = shutil.get_terminal_size((80, 20)).columns

    for step in steps:
        name = "{}{{:<{}}}".format(indent * ' ', max_len + 2)
        name = name.format(step[0] + ':')

        desc = textwrap.wrap(step[1], width=term_width - max_len - 2 - indent)
        second_line_desc = textwrap.indent('\n'.join(desc[1:]),
                                           (max_len + 2 + indent) * ' ')
        desc = '\n'.join([desc[0], second_line_desc]).strip()
        ret += name + desc + '\n'
    return ret.strip()


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
    avail_steps = s_manager.get_steps()

    if args.list_steps:
        print(print_avail_steps(avail_steps))
        sys.exit(0)
    elif not args.input_files:
        parser.error('input_files are required (except -l or -h is set)')

    print("Processing files:", args.input_files[0])
    if len(set(args.step) & set([s.get_name() for s in avail_steps])) > 0:
        msg = 'Invalid step for --step. {}'.format(
            print_avail_steps(avail_steps))
        parser.error(msg)

    s_manager.execute(['DisplayResultsStep'])


if __name__ == '__main__':
    main()
