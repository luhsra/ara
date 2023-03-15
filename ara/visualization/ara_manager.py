# SPDX-FileCopyrightText: 2022 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
from builtins import str

import argparse

import os

import json
from typing import List

from PySide6.QtCore import QObject

from PySide6.QtCore import Slot

from ara.ara import Main
from .signal import ara_signal
from .trace import trace_handler


class ARAManager(QObject):
    """
        Base Class for controlling ARA.
        Should be run in its own thread.
    """

    def copy_main_fields(self):
        self.args = self.main.args
        self.extra_settings = self.main.extra_settings
        self.graph = self.main.graph
        self.s_manager = self.main.s_manager

    def __init__(self):
        super().__init__(None)
        self.main = Main()
        self.copy_main_fields()

    @Slot()
    def init(self):
        """
            Entry Point for ARAs GUI.
        """
        self.main.main(gui=True)
        self.copy_main_fields()

        ara_signal.SIGNAL_MANAGER.sig_init_done.emit()
        ara_signal.SIGNAL_MANAGER.sig_execute_chain.emit(
            self.s_manager.get_execution_chain())

    def get_trace(self):
        return self.s_manager.get_trace()

    @Slot()
    def execute(self):
        self.s_manager.execute(vars(self.args), self.extra_settings,
                               self.args.step)
        ara_signal.SIGNAL_MANAGER.sig_step_done.emit(False, False)

    @Slot()
    def finish_execution(self, program_config):
        self.s_manager.finish_execution(program_config)
        ara_signal.SIGNAL_MANAGER.sig_finish_done.emit()

    @Slot()
    def step(self):
        trace_handler.INSTANCE.reset()
        if self.s_manager.step() == 0:
            ara_signal.SIGNAL_MANAGER.sig_step_done.emit(
                len(self.s_manager.get_steps()) > 0,
                not (self.s_manager.get_trace() is None))
        else:
            ara_signal.SIGNAL_MANAGER.sig_step_dependencies_discovered.emit()
        ara_signal.SIGNAL_MANAGER.sig_execute_chain.emit(
            self.s_manager.get_execution_chain())

    @Slot()
    def finish(self):
        if self.args.ir_output:
            self.s_manager.execute(vars(self.args), {
                'steps': [{
                    'name': 'IRWriter',
                    'ir_file': self.args.ir_output
                }]
            }, None)


INSTANCE = ARAManager()
