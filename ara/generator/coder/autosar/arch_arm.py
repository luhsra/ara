# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later

from .arch_generic import GenericArch
from ..elements import *
from ara.os.autosar import Task, ISR
import os

from ara.graph import ABBType


class ArmArch(GenericArch):

    def __init__(self):
        super(ArmArch, self).__init__()
        self.IPI_SIG = 1  # IPI is just a resehdule interrupt on remote core
        self.TERM_SIG = 12

    def generate_startup_code(self):
        # generate other functions
        self.arch_rules.generate_functions()

    def generate_functions(self):
        kickoff = Function("AUTOSAR_kickoff", "void", [], extern_c=True)
        kickoff.add(Statement("debug_core << __FUNCTION__ << endl"))

        self.call(kickoff, "Machine::enable_interrupts")
        self.call(kickoff, "Machine::switch_mode", "void", ["Machine::USER"])
        self.generator.source_file.function_manager.add(kickoff)

        self.generator.source_file.include("pmu.h")

    # config-constraint-: (arch.self == posix) -> !arch.mpu
    def generate_linkerscript(self):
        linker_script = LinkerScriptTemplate(self)
        filename = os.path.splitext(self.generator.file_prefix)[0] + ".ld"
        with open(filename, 'w+') as fd:
            content = linker_script.expand()
            fd.write(content)

    def generate_data_objects(self):
        """Generate all dataobjects for the system"""
        self.generate_dataobjects_task_stacks()  # From GenericArch
        self.generate_dataobjects_task_entries()  # From GenericArch
        self.generate_dataobjects_tcbs()

    def generate_dataobjects_task_stacks(self):
        """Generate the stacks for the tasks, including the task pointers"""
        super(ArmArch, self).generate_dataobjects_task_stacks()

        # Additional to the general stacks, we also need an array of
        # stack array pointers.
        stackptr_arr = DataObjectArray("void * const", "OS_stackptrs", "")
        stackptr_arr[0] = "&startup_sp"

        arr_idx = 0
        for v, task in self.ara_graph.instances.get(Task):
            arr_idx += 1
            stackptr_arr[arr_idx] = "&" + task.impl.stackptr.name
        self.generator.source_file.data_manager.add(stackptr_arr,
                                                    namespace=("arch", ))

    #def generate_functions(self):
    #    self.generate_enable_irq_after_kernel()

    def generate_dataobjects_tcbs(self):
        for v, task in self.ara_graph.instances.get(Task):
            initializer = "(&%s, %s, %s, %d, %s)" % (
                task.impl.entry_function.name,
                task.impl.stack.name,
                task.impl.stackptr.name,
                task.impl.task_id,
                task.impl.stacksize,
            )

            tcb = DataObject("const arch::TCB", "OS_" + task.name + "_tcb",
                             initializer)
            tcb.allocation_prefix = "constexpr "
            self.generator.source_file.data_manager.add(tcb,
                                                        namespace=("arch", ))
            task.impl.tcb_descriptor = tcb

    def generate_dataobjects_tcbs(self):
        self.generator.source_file.include("tcb.h")

        tcb_arr = DataObjectArray("const TCB * const", "OS_tcbs", "")
        tcb_arr[0] = "0"
        arr_idx = 0

        for v, task in self.ara_graph.instances.get(Task):
            arr_idx += 1
            # Ignore the Idle thread
            #if not subtask.is_real_thread():
            #    continue
            initializer = "(&%s, %s, %s, %s)" % (
                task.impl.entry_function.name, task.impl.stack.name,
                task.impl.stackptr.name, task.impl.stacksize)

            desc = DataObject("const arch::TCB", "OS_" + task.name + "_tcb",
                              initializer)
            desc.allocation_prefix = "constexpr "
            self.generator.source_file.data_manager.add(desc,
                                                        namespace=("arch", ))
            task.impl.tcb_descriptor = desc
            tcb_arr[arr_idx] = "&" + desc.name

        self.generator.source_file.data_manager.add(tcb_arr,
                                                    namespace=("arch", ))

    def generate_isr(self, isr):
        self.generator.source_file.include("machine.h")
        self.generator.source_file.include("gic.h")

        isr.function_name = "AUTOSAR_ISR_" + isr.name
        irq_number = isr.device

        # TODO: GICv1 only?
        # https://developer.arm.com/documentation/ihi0048/b/Programmers--Model/Distributor-register-descriptions/Software-Generated-Interrupt-Register--GICD-SGIR?lang=en
        if (isr.device >= 16):
            self._log.warning(f"isr {isr.device} > 16")
            irq_number = irq_number % 16

        handler = FunctionDefinitionBlock('ISR', [str(irq_number)])
        self.generator.source_file.function_manager.add(handler)

        # Forward declaration for the user defined function
        forward = FunctionDeclaration(isr.function_name, extern_c=True)
        self.generator.source_file.function_manager.add(forward)

        # Forward declaration for our handler
        forward = FunctionDeclaration(f"irq_handler_{irq_number}",
                                      "void*", ["void*", "uint32_t"],
                                      extern_c=True)
        self.generator.source_file.function_manager.add(forward)

        self.call(handler, isr.function_name)

        prio = "IRQ_PRIO_MIN_ISR2"

        # Call give the IRQ a priority at startuo, and enable it
        self.call(self.generator.syscall_rules.StartOS,
                  "arch::GIC::enable_irq",
                  "void", [str(irq_number)],
                  prepend=True)
        self.call(self.generator.syscall_rules.StartOS,
                  "arch::GIC::set_irq_priority",
                  "void", [str(irq_number), prio],
                  prepend=True)

        return irq_number
        pass

    def generate_isr_table(self, isrs):
        self.generator.source_file.include("machine.h")
        self.generator.source_file.include("gic.h")

        installed_irq_handlers = {  #0,      # Dispatch
            1,  # Reschedule
            12,  # TERM
            27,  # V Alarm (raspi)
            #29,     # P Alarm (zedboard)
        }
        for isr in isrs:
            irq_number = self.generate_isr(isr)
            installed_irq_handlers.add(irq_number)

        # Generate the ISR table
        irq_handler_arr = DataObjectArray("arch::irq_handler_t const",
                                          "irq_handlers",
                                          "",
                                          extern_c=True)
        self.generator.source_file.data_manager.add(irq_handler_arr)
        assert max(installed_irq_handlers) + 1 < 96
        for irq in range(0, 96):  # 96 should be enough for everyone
            if irq in installed_irq_handlers:
                irq_handler_arr[irq] = f"/*{irq}*/ irq_handler_{irq}"
            else:
                irq_handler_arr[irq] = f"/*{irq}*/ irq_handler_unhandled"

        # add IPI handler
        IPI_handler = Function("AUTOSAR_ISR_IPI", "void", [], extern_c=True)
        self.generator.syscall_rules.Reschedule(IPI_handler, True)
        self.generator.source_file.function_manager.add(IPI_handler)

        # add termination handler for shutdownAllCores
        TERM_handler = Function("AUTOSAR_ISR_TERM", "void", [], extern_c=True)

        self.call(TERM_handler, "arch::sync_all_hardware_threads", "void",
                  ["SYNC_PRE_SHUTDOWNHOOK"])
        self.call(TERM_handler, "AUTOSAR_ShutdownOS", "void", ["E_OK"])
        self.generator.source_file.function_manager.add(TERM_handler)

        irq_handler_term = Function(f"irq_handler_{self.TERM_SIG}",
                                    "void*", ["void*", "uint32_t"],
                                    extern_c=True)
        self.call(irq_handler_term, "AUTOSAR_ISR_TERM", "void", [])
        irq_handler_term.add(Statement("return arg0"))
        self.generator.source_file.function_manager.add(irq_handler_term)

    def generate_kernelspace(self, userspace, abb, arguments):
        kernelspace = self.generate_kernelspace__syscall(
            userspace, abb, arguments)
        if not userspace.is_isr:
            self.call(userspace, "Machine::switch_mode", "void",
                      ["Machine::USER"])
        return kernelspace


class LinkerScriptTemplate(CodeTemplate):

    def __init__(self, ARM):
        CodeTemplate.__init__(self, ARM.generator, "arch/arm/linker.ld.in")
        self.ARM = ARM
        self.ara_graph = self.ARM.ara_graph

        # Link the foreach_subtask method from the rules
        self.foreach_subtask = self.ARM.generator.syscall_rules.foreach_subtask

    def __select_statement(self, symbol, sections, library="*"):
        """Returns a newline seperated string of linker selectiors, for the
        corresponding sections"""
        ret = ""
        for sec in sections:
            ret += 'KEEP(%s(".%s.%s"));\n' % (library, sec, symbol)
        return ret

    def task_code_regions(self, snippet, args):

        def do(subtask):
            ret = ". = ALIGN(4096);\n"
            ret += "_stext_task%s = .;\n" % subtask.impl.task_id
            # Find all functions that belong to the function
            #TODO adapt
            #for function in self.system_graph.functions:
            #    if subtask == function.subtask:
            #        ret += self.__select_statement(function.function_name, ["text", "rodata"])
            #for function in subtask.impl.generated_functions:
            #    ret += self.__select_statement(function.function_name, ["text", "rodata"])

            ret += "_etext_task%s = .;\n" % subtask.impl.task_id
            ret += "\n"
            return ret

        return self.foreach_subtask(do)

    def task_stacks(self, snippet, args):

        def do(subtask):
            ret = ". = ALIGN(4096);\n"
            ret += "_sstack_task%s = .;\n" % subtask.impl.task_id
            ret += self.__select_statement(subtask.impl.stack.name, ["bss"])
            ret += "_estack_task%s = .;\n" % subtask.impl.task_id
            ret += "\n"
            return ret

        return self.foreach_subtask(do)

    def task_data(self, snippet, args):

        def do(subtask):
            ret = ". = ALIGN(4096);\n"
            ret += "_sdata_task%s = .;\n" % subtask.impl.task_id
            ret += self.__select_statement(subtask.name + "*", ["data"])
            ret += "_edata_task%s = .;\n" % subtask.impl.task_id
            ret += "\n"
            return ret

        return self.foreach_subtask(do)
