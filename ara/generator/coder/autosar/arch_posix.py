from .arch_generic import GenericArch
from ..elements import *
from ara.os.autosar import Task, ISR

class PosixArch(GenericArch):
    isr_device = 37
    def __init__(self):
        super(PosixArch, self).__init__()

    def generate_startup_code(self):
        #TODO is this needed according to spec?
        # Only generate an os_main, if it does not exist
        #if self.system_graph.find(GraphFunction, "os_main") is None:
        #    logging.info("Generating an os_main function calling StartOS")
        #    os_main = Function("os_main", "void", [], extern_c = True)
        #    os_main.add( FunctionCall("StartOS", ["0"]) )
        #    self.source_file.function_manager.add(os_main)

        # TODO move the following to appropriate location

        # Generate a StartOS function and delegate it to the OS rule set
        StartOS = Function("AUTOSAR_StartOS", "void", ["int"], extern_c = True)
        self.syscall_rules.StartOS(StartOS)
        self.generator.source_file.function_manager.add(StartOS)
        self.StartOS = StartOS

        # Generate a ShutdownOS function
        ShutdownOS = Function("AUTOSAR_ShutdownOS", "void", ["StatusType"], extern_c = True)
        self.syscall_rules.ShutdownOS(ShutdownOS)
        self.generator.source_file.function_manager.add(ShutdownOS)

        # Generate the interrupt scheduler
        ASTSchedule = Function("__OS_ASTSchedule", "void", ["int"], extern_c = True)
        self.syscall_rules.ASTSchedule(ASTSchedule)
        self.generator.source_file.function_manager.add(ASTSchedule)

        # TODO add syscalls here
        ## find all syscalls
        #for abb in self.system_graph.implemented_syscalls:
        #    assert abb.subtask != None, "The calling subtask must be set"
#
        #    generated_function = abb.generated_function_name()
        #    abb.impl = SyscallImplementation()
        #    abb.impl.rettype  = self.OSEK_CALLS[abb.syscall_type][0]
        #    abb.impl.argtypes = self.OSEK_CALLS[abb.syscall_type][1:]
#
        #    # Add function definition for the function that is
        #    # _called_ by the application (with __ABB suffix)
        #    userspace = Function(generated_function, abb.impl.rettype, abb.impl.argtypes,
        #                         extern_c = True)
        #    self.stats.add_data(abb, "generated-function", userspace.name)
        #    abb.impl.userspace = userspace
#
        #    # Add userspace function to the userspace
        #    self.source_file.function_manager.add(userspace)
#
        #    # Register userspace function at the subtask, since it
        #    # only callable from there
        #    abb.subtask.impl.generated_functions.append(userspace)
#
        #    self.os_rules.systemcall(abb)


        # Generate the hooks into the operating system
        self.os_rules.generate_hooks()

        # Generate ISRs
        isr_list = [self.ara_graph.instances.vp.obj[v]
            for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], ISR)]

        self.arch_rules.generate_isr_table(isr_list)


        # generate other functions
        self.arch_rules.generate_functions()


    # config-constraint-: (arch.self == posix) -> !arch.mpu
    def generate_linkerscript(self):
        """Posix does not require a linker script"""
        pass

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

        block.add(Statement("sigset_t mask; sigfillset(&mask)"))

        # TODO is this needed ?
        #for isr in self.system_graph.isrs:
        #    if has_scheduler and isr and isr.task.does_promise("serialized"):
        #        device = isr.handler.conf.DEVICE
        #        ready = []
        #        for subtask in isr.task.subtasks:
        #            if not subtask.conf.is_isr:
        #                ready.append("scheduler_.isReady(%s)" % subtask.impl.task_descriptor.name)
#
        #        block.add(Statement("if (%s) { sigdelset(&mask, %s); }" % (
        #            " || ".join(ready), device)))

        block.add(Statement("irq.enable_interrupts(&mask)"))

    def generate_isr(self, isr):
        # Forward declaration for the user defined function
        self.generator.source_file.include("irq.h")

        handler = Function(isr.name + "_wrapper", "void", ["int"])
        self.generator.source_file.function_manager.add(handler)

        #TODO
        # Call kickoff, user defined function, and iret system call
        #kickoff, iret = isr.entry_abb, isr.exit_abb
        #self.call(handler, kickoff.generated_function_name())
        self.call(handler, isr.name)
        #self.call(handler, iret.generated_function_name())


        forward = FunctionDeclaration(isr.name, extern_c=True)
        self.generator.source_file.function_manager.add(forward)

        #TODO dont store in this class
        self.call(self.StartOS,
                           "arch::irq.enable", "void", [str(PosixArch.isr_device)],
                           prepend = True)
        self.call(self.StartOS,
                           "arch::irq.set_handler", "void", [str(PosixArch.isr_device),
                                                             handler.function_name],
                           prepend = True)

        PosixArch.isr_device += 1

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
