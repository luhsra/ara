from ..elements import *
from ..base import BaseCoder
from .implementations import *
#from generator.analysis.types import SyscallType
import logging

from collections import namedtuple

class GenericArch(BaseCoder):
    def __init__(self):
        super(GenericArch, self).__init__()

    def generate_dataobjects_task_stacks(self):
        """Generate the stacks for the tasks, including the task pointers"""
        # Ignore the Idle thread and ISR subtasks
        task_list = [self.ara_graph.instances.vp.obj[v]
            for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        for task in task_list:
            stacksize = str(4096)

            stack = DataObjectArray("uint8_t", task.name + "_stack", stacksize,
                                    extern_c = True)
            self.generator.source_file.data_manager.add(stack)

            stackptr = DataObject("void *", "OS_" + task.name + "_stackptr")
            self.generator.source_file.data_manager.add(stackptr, namespace = ("arch",))

            task.impl.stack = stack
            task.impl.stackptr = stackptr
            task.impl.stacksize = stacksize

    def generate_default_interrupt_handlers(self):
        pass

    def generate_dataobjects_task_entries(self):
        task_list = [self.ara_graph.instances.vp.obj[v]
            for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        for task in task_list:
            entry_function = FunctionDeclaration(TASK_PREFIX + "FUNC_" + task.name, extern_c = True)
            self.generator.source_file.function_manager.add(entry_function)
            task.impl.entry_function = entry_function

    def generate_functions(self):
        pass

    def asm_marker(self, block, label):
        self.call(block, "asm_label", "void", ['"%s"' % label])


    def enable_irq(self, block):
        self.call(block, "Machine::enable_interrupts")

    def enable_irq_after_kernel(self, block):
        self.enable_irq(block)

    def disable_irq(self, block):
        self.call(block, "Machine::disable_interrupts")

    KernelSpace = namedtuple("KernelSpace", ["pre_hook", "system", "post_hook"])
    def generate_kernelspace(self, userspace, abb, arguments):
        """returns a KernelSpace object"""
        raise NotImplementedError()

    def generate_kernelspace__inline(self, userspace, abb, args):
        """When a systemcall is done from a app (synchroanous syscall), then we
           disable interrupts. In the interrupt handler they are already
           disabled.
        """

        call_inst = self.syscall_rules.get_calling_inst(abb)

        if isinstance(call_inst, ISR):
            userspace.is_isr = True
        else:
            userspace.is_isr = False

        userspace.add(Comment("Callsite: %s" % call_inst.name))
        userspace.calling_task = call_inst

        if userspace.is_isr:
            userspace.add(Comment("Called from ISR, no disable interrupts required!"))
        else:
            self.disable_irq(userspace)

        pre_hook  = Hook("SystemEnterHook",arguments =  args)
        system    = Block(arguments = args)
        post_hook = Hook("SystemLeaveHook", userspace.arguments())

        syscall_name = self.ara_graph.cfg.get_syscall_name(abb)[8:]

        userspace.add(pre_hook)
        userspace.add(system)
        userspace.add(post_hook)

        if userspace.is_isr:
            userspace.add(Comment("Called from ISR, no enable interrupts required!"))
        elif syscall_name in ["TerminateTask","ChainTask"]:
            userspace.add(Comment("Terminating Task: return with closed interrupts"))
        else:
            self.enable_irq_after_kernel(userspace)

        return self.KernelSpace(pre_hook, system, post_hook)

