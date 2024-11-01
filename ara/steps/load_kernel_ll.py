# SPDX-License-Identifier: GPL-3.0-or-later

from .option import Option, String
from .step import Step

from ara.os.zephyr import Zephyr

class LoadKernelLL(Step):
    """
    Set the kernel ll file path.
    """

    #kernel_ll_file = Option(name="kernel_ll", help="Path to kernel LLVM-IR file.", ty=String())

    def run(self):
        # self._graph.os.llvm_ir_file = self._step_manager._config.program['input_file']
        Zephyr.llvm_ir_file = self._step_manager._config.program['input_file']
