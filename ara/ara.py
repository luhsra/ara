#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2019 Benedikt Steinmeier
# SPDX-FileCopyrightText: 2019 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Kenny Albes
# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

# vim: set et ts=4 sw=4:
"""Automatic Real-time System Analyzer"""

import argparse
import json
import os
import sys
import logging

# see https://git.skewed.de/count0/graph-tool/-/issues/766
os.environ["OMP_WAIT_POLICY"] = "passive"
import graph_tool

from .graph import Graph
from .stepmanager import StepManager
from .util import init_logging
from .visualization.util import USING_ARA_GUI
from .os import get_os_names, get_os

from .steplisting import print_avail_steps


class Main:
    def __init__(self):
        self.args = None
        self.extra_settings = {}
        self.graph = Graph()
        self.s_manager = StepManager(self.graph)

    def main(self):
        """Entry point for ARA."""
        parser = argparse.ArgumentParser(
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
        parser.add_argument('--dump-prefix', default=os.path.join('dumps', '{step_name}.{uuid}.'),
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
        parser.add_argument('--step-data', default=False, const='dump', nargs='?',
                            help="Emit step data into dumps folder or optionally"
                            " given file", metavar="FILE")
        parser.add_argument('--entry-point', '-e', help="system entry point",
                            default='main')
        parser.add_argument('--isr', '-i', action='append',
                            help="entry point for interrupt service routine")
        parser.add_argument('--step', '-s', action='append',
                            help="choose steps that will be executed")
        parser.add_argument('input_file', help="the LLVM-IR input file", nargs='?')
        parser.add_argument('--oilfile',
                            help="Path to the JSON OIL file (AUTOSAR specific)")
        parser.add_argument('--kconfigfile',
                            help="Path to the Kconfig file (Zephyr specific)")
        parser.add_argument('--timings', help="file for ABB timings. "
                                              "See ApplyTimings for more info.")
        parser.add_argument('--va-corrections', help='Give manual hints to the'
                                                     ' Value Analyzer, see '
                                                     'ValueAnalyzerCorrections step')
        parser.add_argument('--generator_output', metavar="FILE",
                            help="file to store generated OS code")
        parser.add_argument('--step-settings', metavar="FILE", action='append',
                            help="settings for individual steps. '-' is STDIN. "
                                 "Later given settings override previous ones.")
        parser.add_argument('--dependency_file',
                            help="file to write make-style dependencies into for "
                                "build system integration")
        parser.add_argument('--ir_output', '-o',
                            help="File to store modified IR into", metavar="FILE")
        parser.add_argument('--Werr', help="Treat warnings as errors",
                            action='store_true')
        parser.add_argument('--threads',
                            help="Number of threads (set 0 for automatic)",
                            type=int,
                            default=int(os.environ.get('ARA_THREADS', 0)))
        parser.add_argument('--manual-corrections', metavar="FILE",
                            help="File with manual corrections")
        if USING_ARA_GUI:
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

        if self.args.threads > 0:
            graph_tool.openmp_set_num_threads(self.args.threads)
            os.environ["MKL_NUM_THREADS"] = str(self.args.threads)
            os.environ["NUMEXPR_NUM_THREADS"] = str(self.args.threads)
            os.environ["OMP_NUM_THREADS"] = str(self.args.threads)

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

        def step_sneak_in(arg, step_name, after=False):
            if arg:
                if self.args.step:
                    steps = [self.args.step]
                    self.args.step = None
                else:
                    steps = self.extra_settings["steps"]
                if after:
                    steps.append(step_name)
                else:
                    steps.insert(0, step_name)
                self.extra_settings["steps"] = steps

        step_sneak_in(self.args.manual_corrections, "ManualCorrections",
                      after=True)
        step_sneak_in(self.args.va_corrections, "ValueAnalyzerCorrections")
        #step_sneak_in(self.args.timings, "ApplyTimings")

        self.graph.os = get_os(self.args.os)

        if self.args.step is None and not self.extra_settings.get("steps", None):
            self.args.step = ['SIA']
            if self.args.generator_output:
                # we probably want the generator when we specify that option
                logger.info("A generator output was requested. Turn on the generator.")
                self.args.step = ['Generator']

        s_args = dict([(x, y) for x, y in vars(self.args).items() if y is not None])

        if USING_ARA_GUI:
            s_args['trace_algorithm'] = not self.args.no_trace_algorithm
            self.s_manager.init_execution(s_args, self.extra_settings, self.args.step)
            return

        self.s_manager.execute(s_args, self.extra_settings, self.args.step)

        if self.args.ir_output:
            self.s_manager.execute(s_args,
                            {'steps': [{'name': 'IRWriter',
                                        'ir_file': self.args.ir_output}]}, None)

        if logger.level <= logging.DEBUG:
            def step_info(step_entry):
                config = json.dumps(step_entry.all_config, indent=2)
                return f"{step_entry.uuid} {step_entry.name} Config:\n{config}"
        else:
            def step_info(step_entry):
                return f"{step_entry.uuid} {step_entry.name}"

        #logger.info("History: \n" + "\n".join([step_info(se)
        #                                       for se in self.s_manager.get_history()]))


if __name__ == '__main__':
    main = Main()
    main.main()
