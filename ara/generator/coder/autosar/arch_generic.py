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
            #if subtask.conf.basic_task:
            #    # With a stacksize of 8, we indicate we're having a
            #    # basic task here, that runs on the shared stack
            #    stacksize = 8
#
            #    stack = DataObjectArray("uint8_t", subtask.name + "_dynamic_state", str(stacksize),
            #                            extern_c = True)
            #    self.generator.source_file.data_manager.add(stack)
#
#
            #    # Get a common stack pointer for all basic tasks
            #    if not self.system_graph.impl.basic_task_stackptr:
            #        basic_stack = DataObjectArray("uint8_t __attribute__((aligned(4096)))", "shared_basic_stack", "4096",
            #                                      extern_c = True)
            #        stackptr = DataObject("void *", "OS_basic_task_stackptr",
            #                              static_initializer = (basic_stack.name + "+ 4096"), extern_c = True)
            #        self.generator.source_file.data_manager.add(basic_stack, namespace = ("arch",))
            #        self.generator.source_file.data_manager.add(stackptr, namespace = ("arch",))
            #        self.system_graph.impl.basic_task_stackptr = stackptr
            #    else:
            #        stackptr = self.system_graph.impl.basic_task_stackptr
            #else:
            if (True):
                stacksize = str(4096)

                stack = DataObjectArray("uint8_t", task.name + "_stack", stacksize,
                                        extern_c = True)
                self.generator.source_file.data_manager.add(stack)

                stackptr = DataObject("void *", "OS_" + task.name + "_stackptr")
                self.generator.source_file.data_manager.add(stackptr, namespace = ("arch",))

            task.impl.stack = stack
            task.impl.stackptr = stackptr
            task.impl.stacksize = stacksize


        # create basic-task stack for semi-extended tasks
        ## TODO: only needed if systemconfiguration enabled set's in the first place
        #if not self.system_graph.impl.basic_task_stackptr:
        #    basic_stack = DataObjectArray("uint8_t __attribute__((aligned(4096)))", "shared_basic_stack", "4096",
        #                                  extern_c = True)
        #    stackptr = DataObject("void *", "OS_basic_task_stackptr",
        #                          static_initializer = (basic_stack.name + "+ 4096"), extern_c = True)
        #    self.generator.source_file.data_manager.add(basic_stack, namespace = ("arch",))
        #    self.generator.source_file.data_manager.add(stackptr, namespace = ("arch",))
        #    self.system_graph.impl.basic_task_stackptr = stackptr

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

    def kickoff(self, abb, block):
        self.enable_irq_after_kernel(block)

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

        task = self.syscall_rules.get_calling_task(abb)

        from_interrupt = False
        if task == None:
            task = self.syscall_rules.get_calling_isr(abb)
            from_interrupt = True

        userspace.add(Comment("Callsite: %s" % task.name))
        userspace.calling_task = task
        userspace.is_isr = from_interrupt

        if from_interrupt:
            userspace.add(Comment("Called from ISR, no disable interrupts required!"))
        else:
            self.disable_irq(userspace)

        #TODO fix args
        #self.convert_argument(userspace, args[1])
        #self.convert_argument(abb.impl.userspace, args[2])

        pre_hook  = Hook("SystemEnterHook",arguments =  args)
        system    = Block(arguments = args)
        post_hook = Hook("SystemLeaveHook", userspace.arguments())


        syscall_name = self.ara_graph.cfg.get_syscall_name(abb)[8:]

        if syscall_name in [
            "EnableAllInterrupts", "ResumeAllInterrupts", "ResumeOSInterrupts", "kickoff", "iret"
        ]:
            userspace.add(pre_hook)
            userspace.add(post_hook)
            userspace.add(system)
        elif syscall_name in [
            "DisableAllInterrupts", "SuspendAllInterrupts", "SuspendOSInterrupts", "SetRelAlarm"
        ]:
            userspace.add(system)
            userspace.add(pre_hook)
            userspace.add(post_hook)
        else:
            userspace.add(pre_hook)
            userspace.add(system)
            userspace.add(post_hook)

        if from_interrupt:
            userspace.add(Comment("Called from ISR, no enable interrupts required!"))
        elif syscall_name in ["TerminateTask","ChainTask"]:
            userspace.add(Comment("Terminating Task: return with closed interrupts"))
        else:
            self.enable_irq_after_kernel(userspace)

        return self.KernelSpace(pre_hook, system, post_hook)

