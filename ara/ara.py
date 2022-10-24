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
from .visualization.util import SUPPORT_FOR_GUI
from .os import get_os_names, get_os

from .steplisting import print_avail_steps


class Main:

    def __init__(self):
        self.args = None
        self.extra_settings = {}
        self.graph = Graph()
        self.s_manager = StepManager(self.graph)

    def main(self, gui=False):
        """Entry point for ARA.
        
        gui: set to True if ARAs GUI is activated (gui.py was called instead of ara.py)
        """
        if not SUPPORT_FOR_GUI:
            assert not gui, "main(): gui set to True but gui is not supported"

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
        parser.add_argument('--timings', help="file for ABB timings. "
                                            "See ApplyTimings for more info.")
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
        if gui:
            parser.add_argument('--no_trace_algorithm', action='store_true',
                                default=False, help=
                                "Create a trace of supported algorithms for the gui to visualize")
        else:
            parser.add_argument('--trace_algorithm', action='store_true', default=False,
                                help="Create a trace of supported algorithms for the gui to visualize")

        parser.add_argument('--os', help="the OS of the given application",
                            choices=get_os_names())

        # option for [sysfuncts, systemrelevantfunctions]:
        parser.add_argument('--with-stubs', help="analyze system functions that "
                                                "are only stubs. usually, this is"
                                                " only helpful for debugging "
                                                "purposes.",
                            action='store_true', default=False)

        self.args = parser.parse_args()

        if self.args.log_level != 'debug' and self.args.verbose:
            self.args.log_level = 'info'

        logger = init_logging(level=self.args.log_level, root_name='ara',
                              werr=self.args.Werr)

        avail_steps = self.s_manager.get_steps()

        if self.args.list_steps:
            print(print_avail_steps(avail_steps))
            sys.exit(0)
        elif not self.args.input_file:
            parser.error('an input_file is required (except -l or -h is set)')
        elif not self.args.os:
            parser.error('setting of --os is required (except -l or -h is set)')

        logger.debug(f"Processing file: {self.args.input_file}")

        self.extra_settings = {}

        if self.args.step_settings:
            self.extra_settings = {}
            for ssettings in self.args.step_settings:
                try:
                    if ssettings == '-':
                        self.extra_settings = {**self.extra_settings, **json.load(sys.stdin)}
                    else:
                        with open(ssettings) as efile:
                            self.extra_settings = {**self.extra_settings, **json.load(efile)}
                except Exception as e:
                    parser.error(f'File for --step-settings is malformed: {e}')

        if self.extra_settings.get("steps", None) and self.args.step:
            parser.error("Provide steps either with '--step' or in '--step-settings'.")

        if self.args.manual_corrections:
            if self.args.step:
                self.extra_settings["steps"] = [self.args.step, "ManualCorrections"]
                self.args.step = None
            else:
                self.extra_settings["steps"].append("ManualCorrections")

        self.graph.os = get_os(self.args.os)

        if self.args.step is None and not self.extra_settings.get("steps", None):
            self.args.step = ['SIA']

        s_args = dict([(x, y) for x, y in vars(self.args).items() if y is not None])
        
        if gui:
            s_args['trace_algorithm'] = not self.args.no_trace_algorithm
            self.s_manager.init_execution(s_args, self.extra_settings, self.args.step)
            return

        self.s_manager.execute(s_args, self.extra_settings, self.args.step)

        if self.args.ir_output:
            self.s_manager.execute(s_args,
                            {'steps': [{'name': 'IRWriter',
                                        'ir_file': self.args.ir_output}]}, None)

        logger.info("History: \n" + "\n".join([f"{se.uuid} {se.name}"
                                            for se in self.s_manager.get_history()]))


if __name__ == '__main__':
    main = Main()
    main.main(gui=False)
