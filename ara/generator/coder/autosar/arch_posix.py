from .arch_generic import GenericArch
from ..elements import *
from ara.os.autosar import Task

class PosixArch(GenericArch):
    def __init__(self):
        super(PosixArch, self).__init__()

    def generate_startup_code(self):
        pass

    # config-constraint-: (arch.self == posix) -> !arch.mpu
    def generate_linkerscript(self):
        """Posix does not require a linker script"""
        #with self.generator.open_file("linker.ld") as fd:
        #    fd.write("IGNORED IN POSIX")

    def generate_data_objects(self):
        """Generate all dataobjects for the system"""
        self.generate_dataobjects_task_stacks() # From GenericArch
        self.generate_dataobjects_task_entries() # From GenericArch
        self.generate_dataobjects_tcbs()

    def generate_functions(self):
        self.generate_enable_irq_after_kernel()

    def generate_dataobjects_tcbs(self):
        self.generator.source_file.include("tcb.h")
        task_list = [self.ara_graph.instances.vp.obj[v]
            for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        for task in task_list:
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
            self.generator.source_file.data_manager.add(tcb, namespace = ("arch",))
            task.impl.tcb_descriptor = tcb

    def generate_enable_irq_after_kernel(self):
        """Enable only those interrupts that can happen according to the OIL
        model."""
        block = Function("__OS_enable_irq_after_kernel", "void",[])
        self.generator.source_file.function_manager.add(block)

        # When there is no scheduler we enable all external devices
        has_scheduler = self.syscall_rules.has_scheduler_object

        block.add(Statement("sigset_t mask; sigfillset(&mask)"))
        for isr in self.system_graph.isrs:
            if has_scheduler and isr and isr.task.does_promise("serialized"):
                device = isr.handler.conf.DEVICE
                ready = []
                for subtask in isr.task.subtasks:
                    if not subtask.conf.is_isr:
                        ready.append("scheduler_.isReady(%s)" % subtask.impl.task_descriptor.name)

                block.add(Statement("if (%s) { sigdelset(&mask, %s); }" % (
                    " || ".join(ready), device)))

        block.add(Statement("irq.enable_interrupts(&mask)"))

    def generate_isr(self, isr):
        # Forward declaration for the user defined function
        self.generator.source_file.include("irq.h")

        isr_desc = self.generator.system_graph.get(Subtask, isr.name)

        handler = Function(isr_desc.function_name + "_wrapper", "void", ["int"])
        self.generator.source_file.function_manager.add(handler)

        # Call kickoff, user defined function, and iret system call
        kickoff, iret = isr.entry_abb, isr.exit_abb
        self.call(handler, kickoff.generated_function_name())
        self.call(handler, isr.function_name)
        self.call(handler, iret.generated_function_name())


        forward = FunctionDeclaration(isr.function_name, extern_c=True)
        self.generator.source_file.function_manager.add(forward)

        self.call(self.system_graph.impl.StartOS,
                           "arch::irq.enable", "void", [str(isr_desc.conf.isr_device)],
                           prepend = True)
        self.call(self.system_graph.impl.StartOS,
                           "arch::irq.set_handler", "void", [str(isr_desc.conf.isr_device),
                                                             handler.function_name],
                           prepend = True)

    def generate_isr_table(self, isrs):
        self.generator.source_file.include("machine.h")
        for isr in isrs:
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

    def get_syscall_argument(self, block, i):
        name, typename = block.arguments()[i]
        return VariableDefinition(typename, name)
