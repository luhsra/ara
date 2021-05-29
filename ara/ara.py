#!/usr/bin/env python3
# vim: set et ts=4 sw=4:
"""Automatic Real-time System Analyzer"""

import argparse
import json
import os
import sys

from .graph import Graph
from .stepmanager import StepManager
from .util import init_logging
from .os import get_os_model_names, get_os_model_by_name
from .steps.syscall_count import SyscallCount

from .steplisting import print_avail_steps


def main():
    """Entry point for ARA."""
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description=sys.modules[__name__].__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--list-steps', '-l', action="store_true",
                        default=False, help="list all available steps")
    parser.add_argument('--verbose', '-v', help="alias for --log-level=info",
                        action="store_true", default=False)
    parser.add_argument('--log-level', help="choose the log level",
                        choices=['warn', 'info', 'debug'],
                        default=os.environ.get('ARA_LOGLEVEL', 'warn'))
    parser.add_argument('--dump', action='store_true', default=bool(os.environ.get('ARA_DUMP', '')),
                        help="emit a meaningful dot graph where possible")
    parser.add_argument('--dump-prefix', default='dumps/{step_name}.{uuid}.',
                        help="path that prefixes all dot files. The string "
                             "'{step_name}' is replaced with the step name. "
                             "The string '{uuid}' is replace with the uuid.")
    parser.add_argument('--runtime-stats', action='store_true', default=False,
                        help="emit statistics about step runtimes.")
    parser.add_argument('--runtime-stats-file', choices=['logger', 'dump'],
                        help="Choose whether emit the data with the logging"
                        " framework or in a separate dump file.",
                        default='logger')
    parser.add_argument('--runtime-stats-format', choices=['human', 'json'],
                        help="Choose whether emit the data in a human readable"
                        " format or in machine readable JSON.",
                        default='human')
    parser.add_argument('--entry-point', '-e', help="system entry point",
                        default='main')
    parser.add_argument('--isr', '-i', action='append',
                        help="entry point for interrupt service routine")
    parser.add_argument('--step', '-s', action='append',
                        help="choose steps that will be executed")
    parser.add_argument('input_file', help="the LLVM-IR input file", nargs='?')
    parser.add_argument('--oilfile', help="name of oilfile")
    parser.add_argument('--generator_output', metavar="FILE",
                        help="file to store generated OS code")
    parser.add_argument('--step-settings', metavar="FILE", action='append',
                        help="settings for individual steps. '-' is STDIN")
    parser.add_argument('--dependency_file',
                        help="file to write make-style dependencies into for "
                             "build system integration")
    parser.add_argument('--ir_output', '-o',
                        help="File to store modified IR into", metavar="FILE")
    parser.add_argument('--Werr', help="Treat warnings as errors",
                        action='store_true')
    parser.add_argument('--manual-corrections', metavar="FILE",
                        help="File with manual corrections")

    os_model_names = get_os_model_names()
    os_model_names.append("auto")
    parser.add_argument('--os', help="Use the specified OS Model.",
                        choices=os_model_names, default="auto")

    # The following arguments set an option for a specific step.
    # If you do not want them to be a global switch, remove them.

    # Option for IRReader
    parser.add_argument('--no-sysfunc-body', help="Runs the RemoveSysfuncBody step after IRReader. "
                                            "This will increase the performance of the analysis and reduces the false-positive syscall detection rate. "
                                            "Warning: Do not use this argument for the synthesis!",
                        action='store_true', default=False)

    # Option for RecursiveFunctions
    parser.add_argument('--no-recursive-funcs', help="Disables the RecursiveFunctions Step to improve performance.",
                        action='store_true', default=False)

    # Option for InteractionAnalysis
    parser.add_argument('--count-syscalls', help="Counts all effective syscalls of the analysis (in INA step) and writes them to stdout. "
                                                 "Requires the InteractionAnalysis step. Make sure to execute this step.",
                        action='store_true', default=False)

    args = parser.parse_args()

    del os_model_names

    if args.log_level != 'debug' and args.verbose:
        args.log_level = 'info'

    logger = init_logging(level=args.log_level, root_name='ara', werr=args.Werr)

    g = Graph()
    s_manager = StepManager(g)
    avail_steps = s_manager.get_steps()

    if args.list_steps:
        print(print_avail_steps(avail_steps))
        sys.exit(0)
    elif not args.input_file:
        parser.error('an input_file is required (except -l or -h is set)')

    logger.debug(f"Processing file: {args.input_file}")

    extra_settings = {}

    if args.step_settings:
        extra_settings = {}
        for ssettings in args.step_settings:
            try:
                if ssettings == '-':
                    extra_settings = {**extra_settings, **json.load(sys.stdin)}
                else:
                    with open(ssettings) as efile:
                        extra_settings = {**extra_settings, **json.load(efile)}
            except Exception as e:
                parser.error(f'File for --step-settings is malformed: {e}')

    if extra_settings.get("steps", None) and args.step:
        parser.error("Provide steps either with '--step' or in '--step-settings'.")

    if args.manual_corrections:
        if args.step:
            extra_settings["steps"] = [args.step, "ManualCorrections"]
            args.step = None
        else:
            extra_settings["steps"].append("ManualCorrections")
    
    if args.os != "auto":
        g.os = get_os_model_by_name(args.os)

    if args.step is None and not extra_settings.get("steps", None):
        args.step = ['SIA']

    s_manager.execute(vars(args), extra_settings, args.step)

    if args.ir_output:
        s_manager.execute(vars(args),
                          {'steps': [{'name':'IRWriter',
                                      'ir_file': args.ir_output}]}, None)

    logger.info("History: \n" + "\n".join([f"{se.uuid} {se.name}"
                                           for se in s_manager.get_history()]))

    # Print syscall count stats if at least one syscall was counted.
    SyscallCount.print_stats()

if __name__ == '__main__':
    main()
