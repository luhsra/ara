import sys
from builtins import str

import argparse

import os

import json
from typing import List

from PySide6.QtCore import QObject

from PySide6.QtCore import Slot

from .signal import ara_signal
from .trace.trace_type import AlgorithmTrace
from ..graph.graph import Graph
from ..steplisting import print_avail_steps
from ..stepmanager import StepManager
from ..util import init_logging


class ARAManager(QObject):
    """
        Base Class for controlling ARA.
        Should be run in its own thread.
    """

    # sig_setup_done = Signal(name="sigSetupDone")
    #
    # sig_execute_chain = Signal(list)
    # sig_graph = Signal(graph_tool.Graph, name="sigGraph")
    #
    # sig_init_done = Signal()
    # sig_step_done = Signal(bool) # the bool indicates if there are more steps
    # sig_finish_done = Signal()
    #
    # sig_step_dependencies_discovered = Signal()

    def __init__(self):
        super().__init__(None)
        self.args = None
        self.extra_settings = {}
        self.graph = Graph()
        self.s_manager = StepManager(self.graph)

    @Slot()
    def init(self):
        """
            Entry Point for ARA.
            It's mostly a copy of the main in ./ara.py, with slight changes to allow interaction with the gui.
        """

        print("Start")

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
        parser.add_argument('--trace_algorithm', action='store_true', default=False,
                            help="Create a trace of supported algorithms for the gui to visualize")

        self.args = parser.parse_args()

        if self.args.log_level != 'debug' and self.args.verbose:
            self.args.log_level = 'info'

        logger = init_logging(level=self.args.log_level, root_name='ara', werr=self.args.Werr)

        avail_steps = self.s_manager.get_steps()

        if self.args.list_steps:
            print(print_avail_steps(avail_steps))
            sys.exit(0)
        elif not self.args.input_file:
            parser.error('an input_file is required (except -l or -h is set)')

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

        if self.args.step is None and not self.extra_settings.get("steps", None):
            self.args.step = ['SIA']

        self.init_execution(vars(self.args), self.extra_settings, self.args.step)
        ara_signal.SIGNAL_MANAGER.sig_init_done.emit()
        ara_signal.SIGNAL_MANAGER.sig_execute_chain.emit(self.s_manager.get_execution_chain())

    # @Slot()
    def init_execution(self, program_config, extra_config, esteps: List[str]):
        self.s_manager.init_execution(program_config, extra_config, esteps)

    def get_trace(self):
        return self.s_manager.get_trace()

    @Slot()
    def execute(self):
        self.s_manager.execute(vars(self.args), self.extra_settings, self.args.step)
        ara_signal.SIGNAL_MANAGER.sig_step_done.emit(False, False)

    @Slot()
    def finish_execution(self, program_config):
        self.s_manager.finish_execution(program_config)
        ara_signal.SIGNAL_MANAGER.sig_finish_done.emit()

    @Slot()
    def step(self):
        trace_exist = self.s_manager.is_next_step_traceable()

        if self.s_manager.step() == 0:
            ara_signal.SIGNAL_MANAGER.sig_step_done.emit(len(self.s_manager.get_steps()) > 0,
                                                         not(self.s_manager.get_trace() is None))
        else:
            ara_signal.SIGNAL_MANAGER.sig_step_dependencies_discovered.emit()
        ara_signal.SIGNAL_MANAGER.sig_execute_chain.emit(self.s_manager.get_execution_chain())

    @Slot()
    def finish(self):
        if self.args.ir_output:
            self.s_manager.execute(vars(self.args),
                                   {'steps': [{'name': 'IRWriter',
                                               'ir_file': self.args.ir_output}]}, None)


INSTANCE = ARAManager()
