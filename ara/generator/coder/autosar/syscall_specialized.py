# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later

from ..elements import Statement, FunctionCall

from .syscall_generic import GenericSystemCalls


class SpecializedSystemCalls(GenericSystemCalls):

    def log_specialization(self, abb):
        bb = self.ara_graph.cfg.get_entry_bb(abb)
        abb_name = self.ara_graph.cfg.vp.name[abb]
        bb_name = self.ara_graph.cfg.vp.name[bb]
        syscall = self.ara_graph.cfg.get_syscall_name(abb)

        self._log.warning(f"Specialized {syscall} in {bb_name} {abb_name}")

    def ActivateTask(self, syscall, userspace, kernelspace):
        super().ActivateTask(syscall, userspace, kernelspace)

        # check if IPI not needed
        self.avoid_ipi(syscall, kernelspace)

    def SetEvent(self, syscall, userspace, kernelspace):
        super().SetEvent(syscall, userspace, kernelspace)

        # check if IPI not needed
        self.avoid_ipi(syscall, kernelspace)

    def ChainTask(self, syscall, userspace, kernelspace):
        super().ChainTask(syscall, userspace, kernelspace)

        # check if IPI not needed
        self.avoid_ipi(syscall, kernelspace)

    def GetSpinlock(self, syscall, userspace, kernelspace):
        super().GetSpinlock(syscall, userspace, kernelspace)

        # check if Locking not needed
        self.elide_lock(syscall, kernelspace, False)

    def TryToGetSpinlock(self, syscall, userspace, kernelspace):
        super().TryToGetSpinlock(syscall, userspace, kernelspace)

        # check if Locking not needed
        self.elide_lock(syscall, kernelspace, False)

    def ReleaseSpinlock(self, syscall, userspace, kernelspace):
        super().ReleaseSpinlock(syscall, userspace, kernelspace)

        # check if Locking not needed
        self.elide_lock(syscall, kernelspace, True)

    def avoid_ipi(self, abb, block):
        needed = True
        if not self.generator.ara_step.ipi_avoidance.get():
            return

        step_data = self.ara_graph.step_data["IPIAvoidance"]
        for ipi in step_data:  # check results
            if ipi["abb"] != abb:
                continue
            if ipi["ipi_needed"]:  # needed in at least one state
                return True
            needed = False

        if not needed:
            specialized_statement = Statement(
                "debug_core << \"IPI Avoided\" << endl")
            for idx, statement in enumerate(block.inner):
                if isinstance(
                        statement, FunctionCall
                ) and statement.function == "Machine::trigger_interrupt":
                    trigger_call = statement
                    block.inner[idx] = specialized_statement
                    self.log_specialization(abb)

    def elide_lock(self, abb, block, release=False):
        needed = True
        if not self.generator.ara_step.lock_elision.get():
            return
        step_data = self.ara_graph.step_data["LockElision"]["callsites"]

        for lock in step_data.values():  # check results
            if release and lock["release_abb"] != abb:
                continue
            if not release and lock["abb"] != abb:
                continue
            if not lock["elide"]:  # cannot be elided in at least one state
                return True

            needed = False

        if not needed:
            # set "elide" to true
            block.inner[0].arguments.append("true")
            if not release:
                block.add(Statement("debug_core << \"Lock Elided\" << endl"))
            else:
                block.add(Statement("debug_core << \"Unlock Elided\" << endl"))
