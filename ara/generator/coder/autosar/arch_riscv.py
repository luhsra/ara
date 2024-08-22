# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later

from .arch_generic import GenericArch
from ..elements import *
from ara.os.autosar import Task, ISR
import os

from ara.graph import ABBType

from ara.steps import get_native_component
from enum import Enum
 
class TracePerf(Enum):
    NONE = 0
    SYSCALL = 1
    IRQ = 2

class RiscVArch(GenericArch):

    def __init__(self):
        super(RiscVArch, self).__init__()
        #SIGUSR1 on RISCV
        self.IPI_SIG = 1    #Interprocessor Interrupt Signal    Multicore
        self.TERM_SIG = 12  #Termination Signal                 Multicore

    def generate_startup_code(self):
        # generate other functions
        self.arch_rules.generate_functions()
    
    def generate_functions(self):
        super().generate_functions()

        kickoff = Function("AUTOSAR_kickoff", "void", [], extern_c=True)
        #kickoff.add(Statement("debug_core << __FUNCTION__ << endl"))

        self.call(kickoff, "Machine::enable_interrupts")
        self.generator.source_file.function_manager.add(kickoff)

        #self.generator.source_file.include("perf.h")

        if self.PERF_TRACE == TracePerf.IRQ:
            ASTSchedule = self.generator.source_file.function_manager.get("__OS_ASTSchedule")
            if ASTSchedule != None:
                self.call(ASTSchedule, "arch::Perf::trace_cycles", prepend=True)
                
    # config-constraint-: (arch.self == posix) -> !arch.mpu
    def generate_linkerscript(self):
        pass
    
    def generate_data_objects(self):
        # Generate all dataobjects for the system
        self.generate_dataobjects_task_stacks()  # From GenericArch
        self.generate_dataobjects_task_entries()  # From GenericArch
        self.generate_dataobjects_tcbs()

    def generate_system_code(self):
        # tracing for PMU
        self.PERF_TRACE = TracePerf.NONE
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        va = ValueAnalyzer(self.ara_graph)
        PERF_TRACE_global = va.find_global("PERF_TRACE")
        if PERF_TRACE_global is not None:
            self.PERF_TRACE = TracePerf(PERF_TRACE_global.get_initializer().get())

    def generate_dataobjects_tcbs(self):
        self.generator.source_file.include("tcb.h")

        tcb_arr = DataObjectArray("const TCB * const", "OS_tcbs", "")
        tcb_arr[0] = "0"
        arr_idx = 0

        for v, task in self.ara_graph.instances.get(Task):
            # Dynamic state area
            dynamic_state = DataObject("arch::TCB::dynamic_state",
                                        "OS_" + task.name + "_tcb_dynamic")
            dynamic_state.allocation_prefix += " __attribute__((aligned(4)))"

            self.generator.source_file.data_manager.add(dynamic_state, namespace = ("arch",))

            task.impl.dynamic_state = dynamic_state

            arr_idx += 1
            # Ignore the Idle thread
            #if not subtask.is_real_thread():
            #    continue
            initializer = "(&%s, %s, %s, %s)" % (
                task.impl.entry_function.name,
                task.impl.stackptr.name, task.impl.dynamic_state.name, task.impl.stacksize)

            desc = DataObject("const arch::TCB", "OS_" + task.name + "_tcb",
                              initializer)
            # FIXME constexpr sollte an sein
            #desc.allocation_prefix = "constexpr "
            self.generator.source_file.data_manager.add(desc,
                                                        namespace=("arch", ))
            task.impl.tcb_descriptor = desc
            tcb_arr[arr_idx] = "&" + desc.name

        self.generator.source_file.data_manager.add(tcb_arr,
                                                    namespace=("arch", ))

    def generate_isr(self, isr):

        self.generator.source_file.include("machine.h")

        isr.function_name = "AUTOSAR_ISR_" + isr.name
        irq_number = isr.device

        handler = Function(f'irq_handler_{irq_number}', argstype=['unsigned char'], rettype='void')
        handler.unused_parameter(0)
        self.generator.source_file.function_manager.add(handler)

        # Forward declaration for the user defined function
        forward = FunctionDeclaration(isr.function_name, extern_c=True)
        self.generator.source_file.function_manager.add(forward)

        # Forward declaration for our handler
        forward = FunctionDeclaration(f"irq_handler_{irq_number}",
                                      argstype=['unsigned char'], rettype='void')
        self.generator.source_file.function_manager.add(forward)

        self.call(handler, isr.function_name)

        return irq_number

    def generate_isr_table(self, isrs):
        self.generator.source_file.include("interrupt.h")

        installed_irq_handlers = {
            1,  # Reschedule
            12,  # TERM
        #    27,  # V Alarm (raspi)
        #    #29,     # P Alarm (zedboard)
        }
        for isr in isrs:
            irq_number = self.generate_isr(isr)
            installed_irq_handlers.add(irq_number)

        # Generate the ISR table
        irq_handler_arr = DataObjectArray("arch::interrupt_handler_t",
                                          "isr_table",
                                          "")
        self.generator.source_file.data_manager.add(irq_handler_arr, namespace=("arch", ))
        #assert max(installed_irq_handlers) + 1 < 64
        for irq in range(0, 64):
            if irq in installed_irq_handlers:
                irq_handler_arr[irq] = f"/*{irq}*/ irq_handler_{irq}"
            else:
                irq_handler_arr[irq] = f"/*{irq}*/ arch::bad_soft_irq"

        # add termination handler for shutdownAllCores
        TERM_handler = Function("AUTOSAR_ISR_TERM", "void", [], extern_c=True)
#
        self.call(TERM_handler, "arch::sync_all_hardware_threads", "void",
                  ["SYNC_PRE_SHUTDOWNHOOK"])
        self.call(TERM_handler, "AUTOSAR_ShutdownOS", "void", ["E_OK"])
        self.generator.source_file.function_manager.add(TERM_handler)
#
        irq_handler_term = Function(f"irq_handler_{self.TERM_SIG}",
                                    "void", ["unsigned char"],
                                    extern_c=True)
        self.call(irq_handler_term, "AUTOSAR_ISR_TERM", "void", [])
        irq_handler_term.unused_parameter(0)

        self.generator.source_file.function_manager.add(irq_handler_term)

        IPI_handler = Function("AUTOSAR_ISR_IPI", "void", [], extern_c=True)

        self.call(IPI_handler, "scheduler_[AUTOSAR_GetCoreID()].Schedule_impl", "void", ["true"])
        self.generator.source_file.function_manager.add(IPI_handler)
#
        irq_handler_ipi = Function(f"irq_handler_{self.IPI_SIG}",
                                    "void", ["unsigned char"],
                                    extern_c=True)
        self.call(irq_handler_ipi, "AUTOSAR_ISR_IPI", "void", [])
        irq_handler_ipi.unused_parameter(0)

        self.generator.source_file.function_manager.add(irq_handler_ipi)
        

    def generate_kernelspace(self, userspace, abb, arguments):
        # Use the inline kernelspace variant
        return self.generate_kernelspace__inline(userspace, abb, arguments)
