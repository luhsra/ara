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

#TODO Importe Anpassen
 
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

    # Nicht in dOSEK
    def generate_startup_code(self):
        # generate other functions
        self.arch_rules.generate_functions()

    # Gibt es nicht in Posix
    # Gibt es nicht in dOSEK
    
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
    # Posix braucht kein Linkerscript
    # RISCV braucht kein Linkerscript
    def generate_linkerscript(self):
        pass
    """
    # So steht es in dOSEK
    def generate_data_objects(self):
        # Generate all dataobjects for the system
        conf_wired = self.system_graph.conf.os.systemcalls == "wired"
        if conf_wired:
            self.logic = self.system_graph.get_pass("LogicMinimizer")

        # Generate Stacks
        self.generate_dataobjects_task_stacks()
        for subtask in self.system_graph.real_subtasks:
            subtask.impl.stack.allocation_prefix +=" __attribute__((aligned(16))) "

        self.generate_dataobjects_task_entries()
        if conf_wired:
            self.generate_wired_task_descriptors()
            self.generate_rocket_config()
        else:
            self.generate_dataobjects_tcbs()
            # Generate dummy rocket config
            with self.generator.open_file("rocket.config") as fd:
                config = {
                    "coreHartCount":   1,
                    "coreOSEKSyscallWidth": 1,
                    "coreOSEKStateWidth":   1,
                    "coreOSEKInitialState": 0,
                    "coreHartCombinatorics": None,
                    "alarms": {},
                }
                fd.write(json.dumps(config,indent=2, sort_keys=True))


        self.generator.source_file.include("dispatch.h")
    """

    """
    # So steht es in ARM
    # Bleibt gleich
    """
    def generate_data_objects(self):
        # Generate all dataobjects for the system
        self.generate_dataobjects_task_stacks()  # From GenericArch
        self.generate_dataobjects_task_entries()  # From GenericArch
        self.generate_dataobjects_tcbs()

    # Gibt es nicht in Posix
    def generate_system_code(self):
        # tracing for PMU
        self.PERF_TRACE = TracePerf.NONE
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        va = ValueAnalyzer(self.ara_graph)
        PERF_TRACE_global = va.find_global("PERF_TRACE")
        if PERF_TRACE_global is not None:
            self.PERF_TRACE = TracePerf(PERF_TRACE_global.get_initializer().get())

    # Gibt es nicht in Posix
    # Gleicher Name wir darüber
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

    # Hier muss vermutlich viel angepasst werden
    # Interrupt Service Routine
    def generate_isr(self, isr):

        self.generator.source_file.include("machine.h")

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

    # Sehr anders in POSIX
    # Der Interrupt Service Routine Table enthält Pointer auf die ISR Funktionen
    def generate_isr_table(self, isrs):
        return
        self.generator.source_file.include("machine.h")

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
        # Use the inline kernelspace variant
        return self.generate_kernelspace__inline(userspace, abb, arguments)
