from ..elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       Statement, Include, Comment, VariableDefinition,
                       FunctionDeclaration, CodeTemplate, Block, If)

from ..base import BaseCoder

from ara.os.autosar import Resource, Task, Alarm, Counter, ISR, Event

from ara.generator.tools import panic
from ara.graph import ABBType

from itertools import chain

from .syscall_generic import GenericSystemCalls


class SpecializedSystemCalls(GenericSystemCalls):

    def log_specialization(self, abb):
        bb = self.ara_graph.cfg.get_entry_bb(abb)
        abb_name = self.ara_graph.cfg.vp.name[abb]
        bb_name = self.ara_graph.cfg.vp.name[bb]
        syscall = self.ara_graph.cfg.get_syscall_name(abb)

        self._log.warning(f"Specialized {syscall} in {bb_name} {abb_name}")

    def ActivateTask(self, syscall, userspace, kernelspace):
        # check if IPI not needed
        if not self.ipi_needed(syscall):
            self.call(kernelspace, "scheduler_[%d].SetReady_impl"%kernelspace.arguments().task.cpu_id,
                "void", [self.task_desc(kernelspace.arguments().task)])
            kernelspace.add(Statement("debug_core << \"IPI Avoided\" << endl"))

            self.log_specialization(syscall)
        else:
            super().ActivateTask(syscall, userspace, kernelspace)

    def SetEvent(self, syscall, userspace, kernelspace):
        # check if IPI not needed
        if not self.ipi_needed(syscall):
            target_cpu = kernelspace.arguments().task.cpu_id

            tid = str(kernelspace.arguments().task.impl.task_id)
            mask = str(kernelspace.arguments().event_mask)

            self.call(kernelspace, "scheduler_[%d].tlist.set_events"%target_cpu,
                    "void", [tid, mask])

            kernelspace.add(Statement("debug_core << \"IPI Avoided\" << endl"))

            self.log_specialization(syscall)
        else:
            super().SetEvent(syscall, userspace, kernelspace)

    def GetSpinlock(self, syscall, userspace, kernelspace):
        # check if Locking not needed
        if not self.lock_needed(syscall):
            self.call(kernelspace,
                "scheduler_["+str(userspace.calling_task.cpu_id)+"].GetSpinlock_impl",
                "StatusType",
                [self.task_desc(userspace.calling_task), str(kernelspace.arguments().spinlock.impl.descriptor.name), "true"], name = "result")

            self.log_specialization(syscall)
        else:
            super().GetSpinlock(syscall, userspace, kernelspace)


    def ipi_needed(self, abb):
        needed = True
        step_data = self.ara_graph.step_data["IPIAvoidance"]

        for ipi in step_data: # check results
            if ipi["abb"] != abb:
                continue
            if ipi["ipi_needed"]: # needed in at least one state
                return True

            needed = False

        return needed

    def lock_needed(self, abb):
        needed = True
        step_data = self.ara_graph.step_data["LockElision"]["callsites"]

        for lock in step_data.values(): # check results
            if lock["abb"] != abb:
                continue
            if lock["spins"]: # needed in at least one state
                return True

            needed = False

        return needed
