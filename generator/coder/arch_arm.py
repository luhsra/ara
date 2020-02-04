from .arch_generic import GenericArch
from .elements import (DataObjectArray, DataObject)


class ArmArch(GenericArch):

    def static_stack(self, task):
        self.logger.debug("Generating stack for %s", task)
        stack = DataObjectArray("StackType_t",
                                f'{task.name}_static_stack',
                                f'{task.stack_size}',
                                extern_c = True)
        self.generator.source_file.data_manager.add(stack)
        task.impl.stack = stack
        return stack

    def static_unchanged_tcb(self, task):
        self.logger.debug("Generating TCB mem for %s", task)
        tcb = DataObject("StaticTask_t",
                         f'{task.name}_tcb',
                         extern_c = True)
        self.generator.source_file.data_manager.add(tcb)
        task.impl.tcb = tcb
        return tcb
