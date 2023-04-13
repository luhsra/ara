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

    def ActivateTask(self, syscall, userspace, kernelspace):
        # check if IPI not needed
        if not self.ipi_needed(syscall):
            self.call(kernelspace, "scheduler_[%d].SetReady_impl"%kernelspace.arguments().task.cpu_id,
                "void", [self.task_desc(kernelspace.arguments().task)])
            kernelspace.add(Statement("debug_core << \"IPI Avoided\" << endl"))

        else:
            super().ActivateTask(syscall, userspace, kernelspace)


    def ipi_needed(self, abb):
        step_data = self.ara_graph.step_data["IPIAvoidance"]
        states = [self.ara_graph.mstg.vp.state[s] for s in self.ara_graph.mstg.vertices() if self.ara_graph.mstg.vp.state[s] != None]

        for ipi in step_data: # check results
            for state in states:
                if state.id == ipi["state"]: # search for matching state
                    state_abb = state.cpus.one().abb # get abb of state
                    if state_abb != abb:
                        continue
                    if ipi["ipi_needed"] == False:
                        return False
                    else:
                        return True
        return True
