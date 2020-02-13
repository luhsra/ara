#!/usr/bin/env python3
# vim: set et ts=4 sw=4:
"""Automatic Real-time System Analyzer"""

import argparse
import json
import logging
import os
import sys
import util

import graph
import stepmanager
from steplisting import print_avail_steps


def main():
    """Entry point for ARA."""
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description=sys.modules[__name__].__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--verbose', '-v', help="alias for --log-level=info",
                        action="store_true", default=False)
    parser.add_argument('--log-level', help="choose the log level",
                        choices=['warn', 'info', 'debug'], default='warn')
    parser.add_argument('--dump', action='store_true', default=False,
                        help="emit a meaningful dot graph where possible")
    parser.add_argument('--dump-prefix', default='graph/{step_name}',
                        help="path that prefixes all dot files")
    parser.add_argument('--entry-point', '-e', help="system entry point",
                        default='main')
    parser.add_argument('--isr', '-i', action='append',
                        help="entry point for interrupt service routine")
    parser.add_argument('--step', '-s', action='append',
                        help="choose steps that will be executed")
    parser.add_argument('--list-steps', '-l', action="store_true",
                        default=False, help="list all available steps")
    parser.add_argument('input_files', help="all LLVM-IR input files",
                        nargs='*')
    parser.add_argument('--oilfile', help="name of oilfile")
    parser.add_argument('--output_file', help="file to store generated OS code")
    parser.add_argument('--step-settings', metavar="FILE",
                        help="settings for individual steps. '-' is STDIN")
    parser.add_argument('--dependency_file',
                        help="file to write make-style dependencies into for "
                             "build system integration")

    args = parser.parse_args()

    if args.log_level != 'debug' and args.verbose:
        args.log_level = 'info'

    util.init_logging(level=args.log_level)

    logging.debug('ARA executed with: PYTHONPATH=%s python3 %s',
                  os.environ["PYTHONPATH"], ' '.join(sys.argv))

    g = graph.Graph()
    s_manager = stepmanager.StepManager(g)
    avail_steps = s_manager.get_steps()

    if args.list_steps:
        print(print_avail_steps(avail_steps))
        sys.exit(0)
    elif not args.input_files:
        parser.error('input_files are required (except -l or -h is set)')

    logging.debug("Processing files: %s", ', '.join(args.input_files))

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

    if extra_settings.get("steps", None) and args.step:
        parser.error("Provide steps either with '--step' or in '--step-settings'.")

    if args.step is None and not extra_settings.get("steps", None):
        args.step = ['DisplayResultsStep']

    s_manager.execute(vars(args), extra_settings, args.step)


if __name__ == '__main__':
    main()
