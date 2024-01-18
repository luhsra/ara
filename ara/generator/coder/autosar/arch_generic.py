# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later

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
        for v, task in self.ara_graph.instances.get(Task):

            # TODO test basic tasks
            task.impl.basic_task = False

            for n in self.ara_graph.instances.get_out_neighbors(v):
                if isinstance(self.ara_graph.instances.vp.obj[n], Event):
                    task.impl.basic_task = False

            if task.impl.basic_task:
                # With a stacksize of 8, we indicate we're having a
                # basic task here, that runs on the shared stack
                stacksize = 8

                stack = DataObjectArray("uint8_t",
                                        task.name + "_dynamic_state",
                                        str(stacksize),
                                        extern_c=True)
                self.generator.source_file.data_manager.add(stack)

                # Get a common stack pointer for all basic tasks
                if task.cpu_id not in TaskImpl.basic_task_stackptr.keys():
                    basic_stack = DataObjectArray(
                        "uint8_t __attribute__((aligned(4096)))",
                        f"shared_basic_stack_{task.cpu_id}",
                        "4096",
                        extern_c=True)
                    stackptr = DataObject(
                        "void *",
                        f"OS_basic_task_stackptr_{task.cpu_id}",
                        static_initializer=(basic_stack.name + "+ 4096"),
                        extern_c=True)
                    self.generator.source_file.data_manager.add(
                        basic_stack, namespace=("arch", ))
                    self.generator.source_file.data_manager.add(
                        stackptr, namespace=("arch", ))
                    TaskImpl.basic_task_stackptr[task.cpu_id] = stackptr
                else:
                    stackptr = TaskImpl.basic_task_stackptr[task.cpu_id]
            else:
                stacksize = str(4096)

                stack = DataObjectArray("uint8_t",
                                        task.name + "_stack",
                                        stacksize,
                                        extern_c=True)
                self.generator.source_file.data_manager.add(stack)

                stackptr = DataObject("void *",
                                      "OS_" + task.name + "_stackptr")
                self.generator.source_file.data_manager.add(
                    stackptr, namespace=("arch", ))

            task.impl.stack = stack
            task.impl.stackptr = stackptr
            task.impl.stacksize = stacksize

    def generate_default_interrupt_handlers(self):
        pass

    def generate_dataobjects_task_entries(self):
        for v, task in self.ara_graph.instances.get(Task):
            entry_function = FunctionDeclaration(TASK_PREFIX + "FUNC_" +
                                                 task.name,
                                                 extern_c=True)
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

    KernelSpace = namedtuple("KernelSpace",
                             ["pre_hook", "system", "post_hook"])

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
            userspace.add(
                Comment("Called from ISR, no disable interrupts required!"))
        else:
            self.disable_irq(userspace)

        pre_hook = Hook("SystemEnterHook", arguments=args)
        system = Block(arguments=args)
        post_hook = Hook("SystemLeaveHook", userspace.arguments())

        syscall_name = self.ara_graph.cfg.get_syscall_name(abb)[8:]

        userspace.add(pre_hook)
        userspace.add(system)
        userspace.add(post_hook)

        if userspace.is_isr:
            userspace.add(
                Comment("Called from ISR, no enable interrupts required!"))
        elif syscall_name in ["TerminateTask", "ChainTask"]:
            userspace.add(
                Comment("Terminating Task: return with closed interrupts"))
        else:
            self.enable_irq_after_kernel(userspace)

        return self.KernelSpace(pre_hook, system, post_hook)

    def generate_kernelspace__syscall(self, userspace, abb, args):
        """When a systemcall is done from a app (synchronous syscall), then we
           disable interrupts. In the interrupt handler they are already
           disabled.
        """

        call_inst = self.syscall_rules.get_calling_inst(abb)

        if isinstance(call_inst, ISR):
            userspace.is_isr = True
        else:
            userspace.is_isr = False

        pre_hook = Hook("SystemEnterHook", arguments=args)
        system = Block(arguments=args)
        system.add(Statement("result = E_OK"))
        post_hook = Hook("SystemLeaveHook", arguments=userspace.arguments())

        userspace.attributes.append("inlinehint")

        if userspace.is_isr:
            return self.generate_kernelspace__inline(userspace, abb, args)
        else:
            userspace.calling_task = call_inst
            userspace.add(Comment("Callsite: %s" % call_inst.name))

        # Generate a function, that will be executed in system mode,
        # but is specific for this systemcall
        syscall_name = self.ara_graph.cfg.get_syscall_name(abb)

        argstypes = ["StatusType&"]
        args = ["result"]
        signature = self.generator.syscall_rules.AUTOSAR_SYSCALLS[syscall_name]
        if len(signature) > 2:  # additional pointer argument
            argstypes += ["void*"]
            args += ["arg1"]

        syscall = Function("__OS_syscall_" + userspace.function_name,
                           "void",
                           argstypes,
                           extern_c=True)
        syscall.argsname[0] = "result"
        syscall.argsname += ["arg1"]

        self.generator.source_file.function_manager.add(syscall)

        # The syscall function is called from the function that will
        # be inlined into the application
        syscall.add(pre_hook)
        syscall.add(system)

        self.call(userspace, "syscall", "void", [syscall.function_name] + args)
        userspace.add(post_hook)

        # Since we return to userspace with closed interrupts, we have
        # to enable them again.
        self.call(userspace, "Machine::enable_interrupts")

        return self.KernelSpace(pre_hook, system, post_hook)
