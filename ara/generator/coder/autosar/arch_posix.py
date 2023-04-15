from .arch_generic import GenericArch
from ..elements import *
from ara.os.autosar import Task, ISR

from ara.graph import ABBType


class PosixArch(GenericArch):

    def __init__(self):
        super(PosixArch, self).__init__()
        self.IPI_SIG = 10  # SIGUSR1 on x86 Linux
        self.TERM_SIG = 12  # SIGUSR2

    def generate_startup_code(self):
        # generate other functions
        self.arch_rules.generate_functions()

    # config-constraint-: (arch.self == posix) -> !arch.mpu
    def generate_linkerscript(self):
        """Posix does not require a linker script"""
        pass

    def generate_data_objects(self):
        """Generate all dataobjects for the system"""
        self.generate_dataobjects_task_stacks()  # From GenericArch
        self.generate_dataobjects_task_entries()  # From GenericArch
        self.generate_dataobjects_tcbs()

    def generate_functions(self):
        self.generate_enable_irq_after_kernel()

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

    def generate_enable_irq_after_kernel(self):
        """Enable only those interrupts that can happen according to the OIL
        model."""
        block = Function("__OS_enable_irq_after_kernel", "void", [])
        self.generator.source_file.function_manager.add(block)

        block.add(Statement("sigset_t mask; sigfillset(&mask)"))

        block.add(Statement("irq.enable_interrupts(&mask)"))

    def generate_isr(self, isr):
        # Forward declaration for the user defined function
        self.generator.source_file.include("irq.h")

        handler = Function(isr.name + "_wrapper", "void", ["int"])
        self.generator.source_file.function_manager.add(handler)

        self.call(handler, "AUTOSAR_ISR_" + isr.name)

        if not isr.artificial and isr.device in [self.IPI_SIG, self.TERM_SIG]:
            raise ValueError(
                "ISR device {isr.device} conflicts with an internal signal")

        forward = FunctionDeclaration("AUTOSAR_ISR_" + isr.name, extern_c=True)
        self.generator.source_file.function_manager.add(forward)

        self.call(self.generator.syscall_rules.StartOS,
                  "arch::irq.enable",
                  "void", [str(isr.device)],
                  prepend=True)
        self.call(self.generator.syscall_rules.StartOS,
                  "arch::irq.set_handler",
                  "void", [str(isr.device), handler.function_name],
                  prepend=True)

    def generate_isr_table(self, isrs):
        self.generator.source_file.include("machine.h")

        ipi = ISR(cfg=0,
                  name="IPI",
                  cpu_id=0,
                  function=0,
                  priority=0,
                  category=0,
                  device=self.IPI_SIG,
                  artificial=True)

        shutdown = ISR(cfg=0,
                       name="TERM",
                       cpu_id=0,
                       function=0,
                       priority=0,
                       category=0,
                       device=self.TERM_SIG,
                       artificial=True)

        for isr in isrs + [ipi, shutdown]:
            self.generate_isr(isr)

    def enable_irq_after_kernel(self, block):
        """If there is a PROMISE=SERIALIZED, do not allow all interrupts after
           kernel space is left. However, we only do this partial
           enabling if a scheduler object is present in our system.
           This is not true for syscalls=FSM. See
           self.generate_enable_irq_after_kernel for details.

        """
        self.call(block, "__OS_enable_irq_after_kernel")

    def generate_kernelspace(self, userspace, abb, arguments):
        # Use the inline kernelspace variant
        return self.generate_kernelspace__inline(userspace, abb, arguments)
