# SPDX-License-Identifier: GPL-3.0-or-later

from .option import Option, String
from .step import Step

from ara.os.zephyr import Zephyr
from ara.os.zephyr_interpreter import ZephyrInterpreter

class LoadKernelLL(Step):
    """
    Set the kernel ll file path.
    """

    kernel_ll = Option(name="kernel_ll", help="Path to kernel LLVM-IR file.", ty=String())

    def run(self):
        if not 'CONFIG_SCHED_DUMB' in Zephyr.config:
            raise RuntimeError("only CONFIG_SCHED_DUMB supported by SSE")

        # self._graph.os.llvm_ir_file = self._step_manager._config.program['input_file']
        Zephyr.llvm_ir_file = self._step_manager._config.program['input_file']
        Zephyr.llvm_ir_kernel_file = self.kernel_ll.get()

        Zephyr.irx = ZephyrInterpreter(Zephyr.config)

        Zephyr.irx.init(Zephyr.llvm_ir_file, Zephyr.llvm_ir_kernel_file)

