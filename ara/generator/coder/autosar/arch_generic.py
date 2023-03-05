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
            entry_function = FunctionDeclaration(TASK_PREFIX + task.name, extern_c = True)
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

    def generate_kernelspace__inline(self, userspace, abb, arguments):
        """When a systemcall is done from a app (synchroanous syscall), then we
           disable interrupts. In the interrupt handler they are already
           disabled.
        """
        userspace.add(Comment("Subtask: %s" % abb.subtask.name))

        if abb.subtask.conf.is_isr:
            userspace.add(Comment("Called from ISR, no disable interrupts required!"))
        else:
            self.disable_irq(userspace)

        args = [(arg.name, arg.datatype) for arg in arguments]
        pre_hook  = Hook("SystemEnterHook",arguments =  args)
        system    = Block(arguments = args)
        post_hook = Hook("SystemLeaveHook", userspace.arguments())

        if self.system_graph.conf.verify.generate_mockup and not abb.subtask.conf.is_isr:
            if abb.syscall_type.doesTerminateTask():
                pre_hook.add(Statement("%s = 0;" % abb.subtask.impl.instruction_ptr.name))
            else:
                pre_hook.add(Statement("%s = &&resume_label;" % abb.subtask.impl.instruction_ptr.name))
                post_hook.add(Statement("resume_label: (void) 0;"))
                post_hook.add(Statement("%s = 0;" % abb.subtask.impl.instruction_ptr.name))


        userspace.add(pre_hook)
        userspace.add(system)
        userspace.add(post_hook)

        if abb.subtask.conf.is_isr:
            userspace.add(Comment("Called from ISR, no enable interrupts required!"))
        elif abb.syscall_type.doesTerminateTask():
            userspace.add(Comment("Return with closed interrupts"))
        else:
            self.enable_irq_after_kernel(userspace)

        return self.KernelSpace(pre_hook, system, post_hook)

    def generate_kernelspace__syscall(self, userspace, abb, arguments):
        """When a systemcall is done from a app (synchronous syscall), then we
           disable interrupts. In the interrupt handler they are already
           disabled.
        """
        pre_hook  = Hook("SystemEnterHook")
        post_hook = Hook("SystemLeaveHook", userspace.arguments())

        if self.system_graph.conf.verify.generate_mockup and not abb.subtask.conf.is_isr:
            if abb.syscall_type.doesTerminateTask():
                pre_hook.add(Statement("%s = 0;" % abb.subtask.impl.instruction_ptr.name))
            else:
                pre_hook.add(Statement("%s = &&resume_label;" % abb.subtask.impl.instruction_ptr.name))
                post_hook.add(Statement("resume_label: (void) 0;"))
                post_hook.add(Statement("%s = 0;" % abb.subtask.impl.instruction_ptr.name))


        userspace.attributes.append("inlinehint")

        if abb.subtask.conf.is_isr:
            userspace.add(Comment("Called from ISR, no disable interrupts required!"))

            system    = Block(arguments = [(arg.name, arg.datatype) for arg in arguments])

            userspace.add(pre_hook)
            userspace.add(system)
            userspace.add(post_hook)

            return self.KernelSpace(pre_hook, system, post_hook)

        # Generate a function, that will be executed in system mode,
        # but is specific for this systemcall
        syscall = Function("__OS_syscall_" + userspace.function_name,
                           "void", [arg.datatype for arg in arguments], extern_c = True)

        self.generator.source_file.function_manager.add(syscall)
        # Mention the generated function in the stats
        self.stats.add_data(abb, "generated-function", syscall.name)
        # The syscall function is called from the function that will
        # be inlined into the application
        syscall.add(pre_hook)
        self.call(userspace, "syscall", "void", [syscall.function_name] + [str(arg.name) for arg in arguments])
        userspace.add(post_hook)

        # Since we return to userspace with closed interrupts, we have
        # to enable them again.
        self.call(userspace, "Machine::enable_interrupts")

        return self.KernelSpace(pre_hook, syscall, post_hook)
