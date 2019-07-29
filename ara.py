#!/usr/bin/env python3
# vim: set et ts=4 sw=4:
"""Automated Real-time System Analysis"""

import argparse
import sys
import shutil
import textwrap
import logging
import util
import json

import graph
import stepmanager


EXTRA_LEN = len(': ')


def format_steps(name, desc, indent, max_len, width):
    # format name

    if name != '':
        namef = "{}{{:<{}}}".format(indent * ' ', max_len + EXTRA_LEN)
        namef = namef.format(name + ':')
    else:
        namef = (indent + max_len + EXTRA_LEN) * ' '

    # format description
    descl = []
    for line in desc.splitlines():
        descl += textwrap.wrap(line, width=width-max_len-EXTRA_LEN-indent)
    second_line_desc = textwrap.indent('\n'.join(descl[1:]),
                                       (max_len + 2 + indent) * ' ')
    descl = '\n'.join([descl[0], second_line_desc]).strip()

    return namef + descl + '\n'


def print_avail_steps(avail_steps):
    """Return a nice formatted string with all available steps."""
    indent = 2
    ret = "Available Steps:\n"
    steps = sorted([(x.get_name(), x.get_description(), x.config_help())
                    for x in avail_steps])
    max_len = max([len(x[0]) for x in steps])

    term_width = shutil.get_terminal_size((80, 20)).columns

    for step in steps:
        step_text = format_steps(step[0], step[1], indent, max_len, term_width)

        # format extra options
        opt_len = max([0] + [len(x.name) for x in step[2]])
        if step[2]:
            intro = "The step accepts the following options:\n"
            step_text += format_steps("", intro, indent, max_len, term_width)
        for opt in step[2]:
            step_text += format_steps(opt.name, opt.help,
                                      2 * indent + max_len + EXTRA_LEN,
                                      opt_len,
                                      term_width)
        ret += step_text
    return ret.strip()


def main():
    """Entry point for ARSA."""
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description=sys.modules[__name__].__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--verbose', '-v', help="alias for --log-level=info",
                        action="store_true", default=False)
    parser.add_argument('--log-level', help="choose the log level",
                        choices=['warn', 'info', 'debug'], default='warn')
    parser.add_argument('--os', '-O', help="specify the operation system",
                        choices=['freertos', 'osek'], default='osek')
    parser.add_argument('--step', '-s',
                        help="choose steps that will be executed",
                        action='append')
    parser.add_argument('--list-steps', '-l', action="store_true",
                        default=False, help="list all available steps")
    parser.add_argument('input_files', help="all LLVM-IR input files",
                        nargs='*')
    parser.add_argument('--oilfile', help="name of oilfile")
    parser.add_argument('--step-settings', metavar="FILE",
                        help="settings for individual steps")

    args = parser.parse_args()

    if args.log_level != 'debug' and args.verbose:
        args.log_level = 'info'

    util.init_logging(level=args.log_level)

    extra_settings = {}

    if args.step_settings:
        try:
            if args.step_settings == '-':
                extra_settings = json.load(sys.stdin)
            else:
                with open(args.step_settings) as efile:
                    extra_settings = json.load(efile)
        except Exception as e:
            parser.error(f'File for --step-settings is malformed: {e}')

    g = graph.PyGraph()
    s_manager = stepmanager.StepManager(g, vars(args), extra_settings)
    avail_steps = s_manager.get_steps()

    if args.list_steps:
        print(print_avail_steps(avail_steps))
        sys.exit(0)
    elif not args.input_files:
        parser.error('input_files are required (except -l or -h is set)')
    elif args.os == 'OSEK' and not args.oilfile:
        parser.error('when analyzing OSEK and oilfile is required')

    logging.debug("Processing files: %s", ', '.join(args.input_files))

    if args.step is None:
        args.step = ['DisplayResultsStep']

    if len(set(args.step) & set([s.get_name() for s in avail_steps])) == 0:
        msg = 'Invalid step for --step. {}'.format(
            print_avail_steps(avail_steps))
        parser.error(msg)

    logging.debug("Executing steps: %s", ', '.join(args.step))

    s_manager.execute(args.step)


if __name__ == '__main__':
    main()
