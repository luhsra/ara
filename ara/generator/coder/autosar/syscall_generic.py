from ..elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       Statement, Include, Comment, VariableDefinition,
                       FunctionDeclaration, CodeTemplate, Block)

from ..base import BaseCoder

from ara.os.autosar import Resource, Task, Alarm, Counter, ISR
#from generator.transform.GenerateAssertions import AssertionType
#from generator.analysis.Function import Function as GraphFunction
#from generator.analysis.Resource import Resource

from ara.generator.tools import panic
from ara.graph import ABBType


class GenericSystemCalls(BaseCoder):
    AUTOSAR_SYSCALLS = {
        "AUTOSAR_ActivateTask": ["StatusType", "TaskType"],
        "AUTOSAR_ChainTask": ["StatusType", "TaskType"],
        "AUTOSAR_TerminateTask": ["StatusType"],
        "AUTOSAR_EnableAllInterrupts"  : ["void"],
        "AUTOSAR_DisableAllInterrupts" : ["void"],
        "AUTOSAR_ResumeAllInterrupts"  : ["void"],
        "AUTOSAR_SuspendAllInterrupts" : ["void"],
        "AUTOSAR_ResumeOSInterrupts"   : ["void"],
        "AUTOSAR_SuspendOSInterrupts"  : ["void"],
        "AUTOSAR_GetResource": ["StatusType", "ResourceType"],
        "AUTOSAR_ReleaseResource": ["StatusType", "ResourceType"],
        "AUTOSAR_SetEvent": ["StatusType", "TaskType", "EventMaskType"],
        "AUTOSAR_GetEvent": ["StatusType", "TaskType", "EventMaskRefType"],
        "AUTOSAR_ClearEvent": ["StatusType", "EventMaskType"],
        "AUTOSAR_WaitEvent": ["StatusType", "EventMaskType"],
        "AUTOSAR_GetAlarm": ["StatusType", "AlarmType", "TickRefType"],
        "AUTOSAR_SetRelAlarm": ["StatusType", "AlarmType", "TickType", "TickType"],
        "AUTOSAR_CancelAlarm": ["StatusType", "AlarmType"],
    }
    def foreach_subtask(self, func):
        """Call func for every task"""
        ret = []
        task_list = [self.ara_graph.instances.vp.obj[v]
                for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], Task)]
        for task in task_list:
            ret += func(task)
        return ret

    def __init__(self):
        super(GenericSystemCalls, self).__init__()
        self.alarms = AlarmTemplate

    def generate_system_code(self):
        # Use the tasklist and scheduler that is given by the kind of OS (encoded, unencoded)
        self.generator.source_file.declarations.append(self.os_rules.task_list(self).expand())

        self.generator.source_file.include("os/scheduler/scheduler.h")
        self.generator.source_file.include("os/scheduler/task.h")
        self.generator.source_file.declarations.append(self.os_rules.scheduler(self).expand())

        self.generator.source_file.include("os/alarm.h")
        self.generator.source_file.include("os/util/redundant.h")
        self.generator.source_file.declarations.append(self.alarms(self).expand())

        #TODO is this needed according to spec?
        # Only generate an os_main, if it does not exist
        #if self.system_graph.find(GraphFunction, "os_main") is None:
        #    logging.info("Generating an os_main function calling StartOS")
        #    os_main = Function("os_main", "void", [], extern_c = True)
        #    os_main.add( FunctionCall("StartOS", ["0"]) )
        #    self.source_file.function_manager.add(os_main)

        self._log.debug("generate StartOS")
        # Generate a StartOS function and delegate it to the OS rule set
        StartOS = Function("AUTOSAR_StartOS", "void", ["int"], extern_c = True)
        self.syscall_rules.StartOS(StartOS)
        self.generator.source_file.function_manager.add(StartOS)
        self.StartOS = StartOS

        # Generate a ShutdownOS function
        self._log.debug("generate AUTOSAR_ShutdownOS")
        ShutdownOS = Function("AUTOSAR_ShutdownOS", "void", ["StatusType"], extern_c = True)
        self.syscall_rules.ShutdownOS(ShutdownOS)
        self.generator.source_file.function_manager.add(ShutdownOS)

        # Generate the interrupt scheduler
        self._log.debug("generate __OS_ASTSchedule")

        ASTSchedule = Function("__OS_ASTSchedule", "void", ["int"], extern_c = True)
        self.syscall_rules.ASTSchedule(ASTSchedule)
        self.generator.source_file.function_manager.add(ASTSchedule)

        bbs = self.ara_graph.bbs.vertices() # need local ref here

        ## find all syscalls
        for bb in bbs:
            abb = self.ara_graph.cfg.get_abb(bb)

            if abb == None or self.ara_graph.cfg.vp.type[abb] != ABBType.syscall:
                continue

            syscall_name = self.ara_graph.cfg.get_syscall_name(abb)
            bb_name = self.ara_graph.cfg.vp.name[bb]
            abb_name = self.ara_graph.cfg.vp.name[abb]

            self._log.debug("Syscall %s in %s %s", syscall_name, bb_name, abb_name)

            userspace = Function(syscall_name+"_"+bb_name,
                                 self.AUTOSAR_SYSCALLS[syscall_name][0], #rettype
                                 self.AUTOSAR_SYSCALLS[syscall_name][1:], #argtypes
                                 extern_c = True)
            self.generator.source_file.function_manager.add(userspace)

            self.os_rules.systemcall(abb, userspace)


        # Generate the hooks into the operating system
        self.os_rules.generate_hooks()

        # Generate ISRs
        isr_list = [self.ara_graph.instances.vp.obj[v]
            for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], ISR)]

        self.arch_rules.generate_isr_table(isr_list)

    def task_desc(self, subtask):
        """Returns a string that generates the task id"""
        task_desc = subtask.impl.task_descriptor.name
        return task_desc

    def get_calling_task(self,abb):
        fn = self.ara_graph.cfg.get_function(abb)

        for v in self.ara_graph.instances.vertices():
            inst = self.ara_graph.instances.vp.obj[v]
            if isinstance(inst, Task):
                if inst.function == fn:
                    return inst

    def get_calling_isr(self,abb):
        fn = self.ara_graph.cfg.get_function(abb)

        for v in self.ara_graph.instances.vertices():
            inst = self.ara_graph.instances.vp.obj[v]
            if isinstance(inst, ISR):
                if inst.function == fn:
                    return inst

    def get_calling_task_desc(self, abb):
        task = self.get_calling_task(abb)
        return self.task_desc(task)


    def StartOS(self, block):
        block.unused_parameter(0)
        highestTask = None
        task_list = [self.ara_graph.instances.vp.obj[v]
                for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], Task)]

        for task in task_list:
            # Use Reset the stack pointer for all all tasks
            self.call(block, "Dispatcher::Prepare",
                      "void", [self.task_desc(task)])

            if task.autostart:
                self.call(block, "scheduler_["+str(task.cpu_id)+"].SetReadyFromSuspended_impl",
                          "void", [self.task_desc(task)])

            if task.autostart and (not highestTask or task.static_priority > highestTask.static_priority):
                highestTask = task

        # Call the StartupHook
        self.call(block, "CALL_HOOK", "void", ["StartupHook"])

        # Bootstrap: Do the initial syscall
        dispatch_func = Function("__OS_StartOS_dispatch", "void", ["int"], extern_c = True)
        self.generator.source_file.function_manager.add(dispatch_func)
        self.InitialSyscall(dispatch_func)

        self.call(block, "syscall", "void", [dispatch_func.function_name])
        self.call(block, "Machine::unreachable")

    def ShutdownOS(self, block):
        block.unused_parameter(0)

        self.call(block, "CALL_HOOK", "void", ["ShutdownHook", block.arguments_names()[0]])

        block.add(Statement('ShutdownMachine()'))
        self.call(block, "Machine::unreachable")


    def InitialSyscall(self, kernelspace):
        kernelspace.unused_parameter(0)
        self.call(kernelspace, "scheduler_[AUTOSAR_GetCoreID()].Reschedule",
                            "void", [])

    def ASTSchedule(self, kernelspace):
        kernelspace.unused_parameter(0)
        self.call(kernelspace, "scheduler_[AUTOSAR_GetCoreID()].Reschedule",
                               "void", [])


    def kickoff(self, syscall, userspace, kernelspace):
        userspace.attributes.append("inlinehint")
        if not syscall.subtask.conf.is_isr:
            self.arch_rules.kickoff(syscall, userspace)

    def iret(self, syscall, userspace, kernelspace):
        pass

    def TerminateTask(self, syscall, userspace, kernelspace):
        task = self.get_calling_task(syscall)
        self.call(kernelspace, "scheduler_["+str(task.cpu_id)+"].TerminateTask_impl",
                           "void",
                           [self.get_calling_task_desc(syscall)])

    def ActivateTask(self, syscall, userspace, kernelspace):
        args = self.ara_graph.cfg.vp.arguments[syscall]
        task = self.get_calling_task(syscall)
        from_interrupt = "false"
        if task == None:
            task = self.get_calling_isr(syscall)
            from_interrupt = "true"

        self.call(kernelspace,
                           "scheduler_["+str(task.cpu_id)+"].ActivateTask_impl",
                           "void",
                            [self.task_desc(args.task),
                            "/* from_interrupt */ %s" % from_interrupt])
    def ChainTask(self, syscall, userspace, kernelspace):
        args = self.ara_graph.cfg.vp.arguments[syscall]
        task = self.get_calling_task(syscall)
        self.call(kernelspace,
                           "scheduler_["+str(task.cpu_id)+"].ChainTask_impl",
                           "void",
                           [self.get_calling_task_desc(syscall),
                            self.task_desc(args.task)
                            ])


    def WaitEvent(self, syscall, userspace, kernelspace):
        args = self.ara_graph.cfg.vp.arguments[syscall]
        task = self.get_calling_task(syscall)
        self.call(kernelspace,
                           "scheduler_["+str(task.cpu_id)+"].WaitEvent_impl",
                           "void",
                           [self.get_calling_task_desc(syscall),
                            str(args.event_mask) # TODO combine_event_masks ?
                           ])

    def ClearEvent(self, syscall, userspace, kernelspace):
        args = self.ara_graph.cfg.vp.arguments[syscall]
        task = self.get_calling_task(syscall)
        self.call(kernelspace,
                           "scheduler_["+str(task.cpu_id)+"].ClearEvent_impl",
                           "void",
                           [self.get_calling_task_desc(syscall),
                            str(args.event_mask)
                           ])
        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.get_calling_task_desc(syscall)])

    def GetEvent(self, syscall, userspace, kernelspace):
        args = self.ara_graph.cfg.vp.arguments[syscall]
        task = self.get_calling_task(syscall)
        mask = self.call(kernelspace, "scheduler_["+str(task.cpu_id)+"].GetEvent_impl",
                                  "EventMaskType", [self.task_desc(args.task)])

        return_variable = self.os_rules.get_syscall_return_variable("EventMaskType", 4)

        # Fill return variable
        kernelspace.add(Statement("%s.set(%s)"%(
            return_variable.name,
            mask.name)))

        # Read out the result of the system call
        post = syscall.impl.post_hook
        post.add(Statement("%s.check()" %(
            return_variable.name
        )))
        post.add(Statement("*%s = %s.get()" %(
            userspace.arguments()[1][0], # Name of the first argument
            return_variable.name
        )))

        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.get_calling_task_desc(syscall)])



    def SetEvent(self, syscall, userspace, kernelspace):
        userspace.unused_parameter(1)
        args = self.ara_graph.cfg.vp.arguments[syscall]
        task = self.get_calling_task(syscall)
        self.call(kernelspace,
                           "scheduler_["+str(task.cpu_id)+"].SetEvent_impl",
                           "void",
                           [self.task_desc(args.task),
                           str(args.event_mask)
                           ])

    def SetRelAlarm(self, abb, userspace, kernelspace):
        arg1 = self.arch_rules.get_syscall_argument(kernelspace, 0)
        arg2 = self.arch_rules.get_syscall_argument(kernelspace, 1)
        alarm = abb.arguments[0]
        self.call(kernelspace, "%s.setRelativeTime" % alarm.impl.name,
                           "void", [arg1.name])
        self.call(kernelspace, "%s.setCycleTime" % alarm.impl.name,
                           "void", [arg2.name])
        self.call(kernelspace, "%s.setArmed" % alarm.impl.name,
                           "void", ["true"])
        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.get_calling_task_desc(abb)])

    def AdvanceCounter(self, abb, userspace, kernelspace):
        counter = abb.arguments[0]

        # Increase Counter and check the counter
        kernelspace.add(Statement("%s.do_tick()" % counter.impl.name))
        for alarm in self.system_graph.alarms:
            if alarm.conf.counter == counter:
                alarm.carried_syscall.function = abb.function
                check_alarm = self.alarms(self).generate_check_alarm_softcounter(alarm)
                kernelspace.add(Statement(check_alarm))

        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.get_calling_task_desc(abb)])

    def GetAlarm(self, abb, userspace, kernelspace):
        alarm = abb.arguments[0]

        return_variable = self.os_rules.get_syscall_return_variable("TickType")

        # Fill return variable
        kernelspace.add(Statement("%s.set(%s.getRemainingTicks())"%(
            return_variable.name,
            alarm.impl.name)))

        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.get_calling_task_desc(abb)])

        # Read out the result of the system call
        post = abb.impl.post_hook
        post.add(Statement("%s.check()" %(
            return_variable.name
        )))
        post.add(Statement("*%s = %s.get()" %(
            userspace.arguments()[1][0], # Name of the first argument
            return_variable.name
        )))

    def CancelAlarm(self, abb, userspace, kernelspace):
        alarm = abb.arguments[0]
        self.call(kernelspace, "%s.setArmed" % alarm.impl.name,
                           "void", ["false"])
        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.get_calling_task_desc(abb)])

    def GetResource(self, abb, userspace, kernelspace):

        task = self.get_calling_task(abb)
        next_prio = abb.definite_after(E.task_level).dynamic_priority
        self.call(kernelspace,
                           "scheduler_["+str(task.cpu_id)+"].GetResource_impl",
                           "void",
                           [self.get_calling_task_desc(abb),
                            str(next_prio)])

        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.get_calling_task_desc(abb)])

    def ReleaseResource(self, abb, userspace, kernelspace):

        task = self.get_calling_task(abb)
        next_prio = abb.definite_after(E.task_level).dynamic_priority
        if not abb.subtask.conf.preemptable:
            next_prio = self.system_graph.get(Resource, "RES_SCHEDULER").conf.static_priority
        self.call(kernelspace,
                           "scheduler_["+str(task.cpu_id)+"].ReleaseResource_impl",
                           "void",
                           [self.get_calling_task_desc(abb),
                            str(next_prio)])


    # Interrupt Handling
    def disable_irq(self, block, abb):
        before = abb.get_incoming_nodes(E.task_level)
        disabled = [x.interrupt_block_all or x.interrupt_block_os
                    for x in before]
        # If the interrupts were blocked before do not a thing
        if any(disabled):
            assert all(disabled)
            return

        self.arch_rules.disable_irq(block)

    def enable_irq(self, block, abb):
        before = abb.get_outgoing_nodes(E.task_level)
        disabled = [x.interrupt_block_all or x.interrupt_block_os
                    for x in before]
        # If the interrupts were unblocked before do not a thing
        if any(disabled):
            assert all(disabled)
            return

        self.arch_rules.enable_irq_after_kernel(block)

    def DisableAllInterrupts(self, abb, userspace, kernelspace):
        self.disable_irq(kernelspace, abb)
    SuspendAllInterrupts = DisableAllInterrupts
    SuspendOSInterrupts  = DisableAllInterrupts

    def EnableAllInterrupts(self, abb, userspace, kernelspace):
        self.enable_irq(kernelspace, abb)
    ResumeAllInterrupts = EnableAllInterrupts
    ResumeOSInterrupts  = EnableAllInterrupts

class AlarmTemplate(CodeTemplate):
    def __init__(self, rules, alarm_filter = None):
        CodeTemplate.__init__(self, rules.generator, "os/alarm.h.in")
        self.rules = rules
        self.alarm_filter = alarm_filter
        self.ara_graph = self.generator.ara_graph

        # Link the foreach_subtask method from the rules
        self.foreach_subtask = self.rules.foreach_subtask

        # Check if there are any counters/alarms which have to be implemented
        self.subsystem_enabled = False
        alarm_list = [self.ara_graph.instances.vp.obj[v]
            for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], Alarm)]

        if self.alarm_filter:
            if any(self.alarm_filter(x) for x in alarm_list):
                self.subsystem_enabled = True
        else:
            if len(alarm_list) > 0:
                self.subsystem_enabled = True

    def increase_counters(self, snippet, args):
        ret = []

        ctr_list = [self.ara_graph.instances.vp.obj[v]
            for v in self.ara_graph.instances.vertices()
                if isinstance(self.ara_graph.instances.vp.obj[v], Counter)]
        for counter in ctr_list:
            # Softcounters are ignored by the hardware interrupt
            # TODO support softcounters?
            #if counter.conf.softcounter:
            #    continue
            # Ignore all counters, that have no alarm attached, which
            # is actually implemented

            #if self.alarm_filter:
            #    if all(self.alarm_filter(x) is False for x in counter.alarms):
            #        continue
            ret += self.expand_snippet("increase_counter",
                                       name = counter.name)
        return ret


    def generate_check_alarm_softcounter(self, alarm):
        args = {"alarm": alarm.impl.name}

        abb = alarm.carried_syscall
        ret = self.expand_snippet("if_alarm", **args) + "\n"
        userspace, kernelspace = Block(), Block()

        if abb.isA(S.ActivateTask):
            self.rules.syscall_rules.ActivateTask(abb, userspace, kernelspace)
        else:
            self.rules.syscall_rules.SetEvent(abb, userspace, kernelspace)

        ret += "".join(kernelspace.expand(None))
        ret += self.expand_snippet("endif_alarm", **args) + "\n"

        return ret

    def generate_check_alarm(self, alarm):
        callback_name = "OSEKOS_ALARMCB_%s" % (alarm.name)
        has_callback  = (self.system_graph.find(GraphFunction, callback_name) != None)
        args = {"alarm": alarm.impl.name}
        # Add a label to identify this basic block
        ret = ""
        ret += "    abb_%(label)s: (void) &&abb_%(label)s;\n" %{
            "label": alarm.carried_checkalarm.generated_function_name()
        }
        ret += self.expand_snippet("if_alarm", **args) + "\n"
        # This alarm has an callback
        if has_callback:
            # Add a Declaration
            decl = FunctionDeclaration(callback_name, extern_c = True)
            self.generator.source_file.function_manager.add(decl)
            ret += self.expand_snippet("alarm_alarmcallback", callback = callback_name) + "\n"

        carried = alarm.carried_syscall
        # SetEvent needs two arguments
        if alarm.conf.event:
            arglist = "(0, 0)"
        else:
            arglist = "(0)"
        # Add a label to identify this basic block
        ret += "        abb_%(label)s: (void) &&abb_%(label)s;\n" %{
            "label": carried.generated_function_name()
        }
        ret += "        " + carried.generated_function_name() + arglist + ";\n"
        ret += self.expand_snippet("endif_alarm", **args) + "\n"

        return ret

    def generate_check_alarms(self, snippet, args):
        return []
        # TODO support AlarmHandlerSubtask
        if not self.system_graph.AlarmHandlerSubtask:
            return []
        ret = []

        # The AlarmHandlerSubtask carries a _sorted_ list of alarms
        kickoff    = self.system_graph.AlarmHandlerSubtask.entry_abb
        iret    = self.system_graph.AlarmHandlerSubtask.exit_abb

        ret += ["    " + kickoff.generated_function_name() + "();\n"]
        for alarm in self.system_graph.alarms:
            if alarm.conf.counter.conf.softcounter:
                continue
            ret += [self.generate_check_alarm(alarm)]

        ret += ["    " + iret.generated_function_name() + "();\n"]

        return ret
