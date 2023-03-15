# SPDX-FileCopyrightText: 2021 Kenny Albes
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for Sysfuncts."""

from .step import Step
from .option import Option, Bool


class SysFuncts(Step):
    """Label system functions as such and detect the OS."""

    with_stubs = Option(name="with_stubs",
                        help="Do label system functions that are declared as "
                             "stub. This is likely to increase the runtime "
                             "and usually only necessary for debugging.Set "
                             "this option also for SystemRelevantFunctions"
                             " or with --with-stubs.",
                        ty=Bool(),
                        default_value=False)

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def is_syscall(self, syscall_name):
        """Returns True if syscall_name is a syscall for the current OS.

        This method also auto detects the OS if self._graph.os is not set.
        """
        def return_if_no_stub(os, syscall_name):
            if self.with_stubs.get():
                return True
            return not os.syscalls[syscall_name].is_stub

        if self._graph.os is not None:
            if self._graph.os.is_syscall(syscall_name):
                return return_if_no_stub(self._graph.os, syscall_name)
        return False

    def run(self):
        for nod in self._graph.functs.vertices():
            call = self._graph.functs.vp.name[nod]
            self._graph.functs.vp.sysfunc[nod] = self.is_syscall(call)

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + "dot",
                 "graph_name": 'CFG with syscall functions',
                 "subgraph": 'abbs'}
            )
