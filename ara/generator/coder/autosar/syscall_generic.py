from ..elements import (DataObjectArray, DataObject, Function, FunctionCall,
                       Statement, Include, Comment, VariableDefinition,
                       FunctionDeclaration, CodeTemplate, Block, If)

from ..base import BaseCoder

from ara.os.autosar import Resource, Task, Alarm, Counter, ISR, Event

from ara.generator.tools import panic
from ara.graph import ABBType

from itertools import chain


class GenericSystemCalls(BaseCoder):
    AUTOSAR_SYSCALLS = {
        "AUTOSAR_ActivateTask": ["StatusType", "TaskType"],
        "AUTOSAR_ChainTask": ["StatusType", "TaskType"],
        "AUTOSAR_TerminateTask": ["StatusType"],
        "AUTOSAR_GetResource": ["StatusType", "ResourceType"],
        "AUTOSAR_ReleaseResource": ["StatusType", "ResourceType"],
        "AUTOSAR_SetEvent": ["StatusType", "TaskType", "EventMaskType"],
        "AUTOSAR_GetEvent": ["StatusType", "TaskType", "EventMaskRefType"],
        "AUTOSAR_ClearEvent": ["StatusType", "EventMaskType"],
        "AUTOSAR_WaitEvent": ["StatusType", "EventMaskType"],
        "AUTOSAR_GetAlarm": ["StatusType", "AlarmType", "TickRefType"],
        "AUTOSAR_SetRelAlarm": ["StatusType", "AlarmType", "TickType", "TickType"],
        "AUTOSAR_CancelAlarm": ["StatusType", "AlarmType"],
        "AUTOSAR_GetSpinlock": ["StatusType", "SpinlockType"],
        "AUTOSAR_TryGetSpinlock": ["StatusType", "SpinlockType", "int*"],
        "AUTOSAR_ReleaseSpinlock": ["StatusType", "SpinlockType"],
        "AUTOSAR_AdvanceCounter": ["StatusType", "CounterType"],
    }
    def foreach_subtask(self, func):
        """Call func for every task"""
        ret = []
        for v, task in self.ara_graph.instances.get(Task):
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

        self._log.debug("generate StartOS")
        # Generate a StartOS function and delegate it to the OS rule set
        StartOS = Function("AUTOSAR_StartOS", "void", ["int"], extern_c = True)
        self.syscall_rules.StartOS(StartOS)
        self.generator.source_file.function_manager.add(StartOS)
        self.StartOS = StartOS

        # Generate the interrupt scheduler
        self._log.debug("generate __OS_ASTSchedule")

        ASTSchedule = Function("__OS_ASTSchedule", "void", ["int"], extern_c = True)
        self.syscall_rules.ASTSchedule(ASTSchedule)
        self.generator.source_file.function_manager.add(ASTSchedule)

        # add IPI handler
        IPI_handler = Function("AUTOSAR_ISR_IPI", "void", [], extern_c = True)
        self.Reschedule(IPI_handler, True)
        self.generator.source_file.function_manager.add(IPI_handler)

        # add termination handler for shutdownAllCores
        TERM_handler = Function("AUTOSAR_ISR_TERM", "void", [], extern_c = True)

        self.call(TERM_handler, "arch::sync_all_hardware_threads", "void", ["SYNC_PRE_SHUTDOWNHOOK"])
        self.call(TERM_handler, "AUTOSAR_ShutdownOS", "void", ["E_OK"])
        self.generator.source_file.function_manager.add(TERM_handler)


        bbs = self.ara_graph.bbs.vertices() # need local ref here

        ## find all syscalls
        for bb in bbs:
            abb = self.ara_graph.cfg.get_abb(bb)

            if abb == None or self.ara_graph.cfg.vp.type[abb] != ABBType.syscall:
                continue

            syscall_name = self.ara_graph.cfg.get_syscall_name(abb)

            if syscall_name not in self.AUTOSAR_SYSCALLS:
                continue

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
        isr_list = [event for v, event in self.ara_graph.instances.get(ISR)]

        self.arch_rules.generate_isr_table(isr_list)

    def task_desc(self, subtask):
        """Returns a string that generates the task id"""
        task_desc = subtask.impl.task_descriptor.name
        return task_desc

    def get_calling_inst(self, abb):
        fn = self.ara_graph.cfg.get_function(abb)

        callgraph_fn = self.ara_graph.cfg.vp.call_graph_link[fn]

        traversed = False
        while (not traversed):
            callsites = self.ara_graph.callgraph.get_in_neighbors(callgraph_fn)

            if len(callsites) == 0:
                traversed = True
            elif len(callsites) == 1:
                callgraph_fn = callsites[0]
            else:
                self._log.warning("too many callsites for %s, using first one", self.ara_graph.cfg.vp.name[fn])
                callgraph_fn = callsites[0]

        for v, inst in chain(self.ara_graph.instances.get(ISR), self.ara_graph.instances.get(Task)):
                if self.ara_graph.cfg.vp.call_graph_link[inst.function] == callgraph_fn:
                    return inst

    def get_calling_task_desc(self, abb):
        task = self.get_calling_inst(abb)
        return self.task_desc(task)


    def StartOS(self, block):
        block.unused_parameter(0)

        block.add(Statement("debug_core << __FUNCTION__ << endl"))
        block.add(Statement("core_started[GetCoreID()] = true"))

        # prepare and autostarted tasks
        for v, task in self.ara_graph.instances.get(Task):
            core_id = "OS_CORE_ID_"+str(task.cpu_id)
            ifblock = If("GetCoreID() == "+core_id)
            block.add(ifblock)
            self.call(ifblock, "Dispatcher::Prepare",
                "void", [self.task_desc(task)])
            if task.autostart:
                self.call(ifblock, "scheduler_["+core_id+"].SetReadyFromSuspended_impl",
                          "void", [self.task_desc(task)])


        # check if hardware timer is needed
        for v, counter in self.ara_graph.instances.get(Counter):
            if counter.softcounter == False:
                self.generator.source_file.include("itimer.h")
                self.call(block, "ITimer::init")
                break

        # Call the StartupHook
        self.call(block, "CALL_HOOK", "void", ["StartupHook"])

        # Bootstrap: Do the initial syscall
        dispatch_func = Function("__OS_StartOS_dispatch", "void", ["int"], extern_c = True)
        self.generator.source_file.function_manager.add(dispatch_func)
        self.InitialSyscall(dispatch_func)

        self.call(block, "syscall", "void", [dispatch_func.function_name])
        self.call(block, "Machine::unreachable")

    def Reschedule(self, kernelspace, from_interrupt):
        self.call(kernelspace, "scheduler_[AUTOSAR_GetCoreID()].Schedule_impl",
                            "void", [str(from_interrupt).lower()])

    def InitialSyscall(self, kernelspace):
        kernelspace.unused_parameter(0)
        self.Reschedule(kernelspace, False)

    def ASTSchedule(self, kernelspace):
        kernelspace.unused_parameter(0)
        self.Reschedule(kernelspace, False)

    def TerminateTask(self, syscall, userspace, kernelspace):
        self.call(kernelspace, "scheduler_["+str(userspace.calling_task.cpu_id)+"].TerminateTask_impl",
                           "StatusType",
                           [self.task_desc(userspace.calling_task)], name="result")

    def ActivateTask(self, syscall, userspace, kernelspace):
        if userspace.is_isr:
            from_interrupt = "true"
        else:
            from_interrupt = "false"

        curr_cpu = userspace.calling_task.cpu_id
        target_cpu = kernelspace.arguments().task.cpu_id

        self.call(kernelspace, "scheduler_[%d].SetReady_impl"%target_cpu,
                "void", [self.task_desc(kernelspace.arguments().task)])

        if curr_cpu != target_cpu:
            self.call(kernelspace, "Machine::trigger_interrupt", "void", [str(self.generator.arch_rules.IPI_SIG), str(target_cpu), "true"])
        else:
            self.call(kernelspace,
                           "scheduler_[%d].Schedule_impl"%curr_cpu,
                           "void", ["/* from_interrupt */ %s" % from_interrupt])
    def ChainTask(self, syscall, userspace, kernelspace):

        task = userspace.calling_task

        self.call(kernelspace, "scheduler_[%d].SetSuspended_impl"%task.cpu_id,
            "void", [self.task_desc(task)])

        self.ActivateTask(syscall, userspace, kernelspace)

        self.call(kernelspace, "scheduler_[%d].Schedule_impl"%task.cpu_id)

    def GetSpinlock(self, syscall, userspace, kernelspace):
        self.call(kernelspace,
                           "scheduler_["+str(userspace.calling_task.cpu_id)+"].GetSpinlock_impl",
                           "StatusType",
                           [self.task_desc(userspace.calling_task), str(kernelspace.arguments().spinlock.impl.descriptor.name)], name = "result")

    def ReleaseSpinlock(self, syscall, userspace, kernelspace):
        self.call(kernelspace,
                           "scheduler_["+str(userspace.calling_task.cpu_id)+"].ReleaseSpinlock_impl",
                           "StatusType",
                           [self.task_desc(userspace.calling_task), str(kernelspace.arguments().spinlock.impl.descriptor.name)], name = "result")

    def WaitEvent(self, syscall, userspace, kernelspace):
        self.call(kernelspace,
                           "scheduler_["+str(userspace.calling_task.cpu_id)+"].WaitEvent_impl",
                           "StatusType",
                           [self.task_desc(userspace.calling_task),
                            str(kernelspace.arguments().event_mask)
                           ], name = "result")

    def ClearEvent(self, syscall, userspace, kernelspace):
        self.call(kernelspace,
                           "scheduler_["+str(userspace.calling_task.cpu_id)+"].ClearEvent_impl",
                           "void",
                           [self.task_desc(userspace.calling_task),
                            str(kernelspace.arguments().event_mask)
                           ])
        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.task_desc(userspace.calling_task)])

    def GetEvent(self, syscall, userspace, kernelspace):

        task = kernelspace.arguments().task_id

        mask = self.call(kernelspace, f"scheduler_[{task.cpu_id}].GetEvent_impl",
                                  "EventMaskType", [self.task_desc(task)], name = "*arg1")


        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.task_desc(userspace.calling_task)])


    def SetEvent(self, syscall, userspace, kernelspace):
        if userspace.is_isr:
            from_interrupt = "true"
        else:
            from_interrupt = "false"

        curr_cpu = userspace.calling_task.cpu_id
        target_cpu = kernelspace.arguments().task.cpu_id

        tid = str(kernelspace.arguments().task.impl.task_id)
        mask = str(kernelspace.arguments().event_mask)

        self.call(kernelspace, "scheduler_[%d].tlist.set_events"%target_cpu,
                "void", [tid, mask])

        if curr_cpu != target_cpu:
            self.call(kernelspace, "Machine::trigger_interrupt", "void", [str(self.generator.arch_rules.IPI_SIG), str(target_cpu), "true"])
        else:
            self.call(kernelspace,
                           "scheduler_[%d].Schedule_impl"%curr_cpu,
                           "void", ["/* from_interrupt */ %s" % from_interrupt])

    def SetRelAlarm(self, syscall, userspace, kernelspace):
        alarm = kernelspace.arguments().alarm
        #cycle = kernelspace.arguments().cycle
        #increment = kernelspace.arguments().increment

        self.call(kernelspace, "%s.setRelativeTime" % alarm.impl.name,
                           "void", ["arg1"])
        self.call(kernelspace, "%s.setCycleTime" % alarm.impl.name,
                           "void", ["arg2"])
        self.call(kernelspace, "%s.setArmed" % alarm.impl.name,
                           "void", ["true"])
        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.task_desc(userspace.calling_task)])

    def AdvanceCounter(self, syscall, userspace, kernelspace):
        counter = kernelspace.arguments().counter

        if (not counter.softcounter):
            kernelspace.add(Statement("result = E_OS_ID"))
            return

        kernelspace.add(Statement("%s.do_tick()" % counter.impl.name))

        for v, alarm in self.ara_graph.instances.get(Alarm):
            if alarm.impl.counter == counter:
                check_alarm = self.alarms(self).generate_check_alarm(alarm, userspace.is_isr, userspace.calling_task.cpu_id)
                kernelspace.add(Statement(check_alarm))

        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.task_desc(userspace.calling_task)])

    def GetAlarm(self, abb, userspace, kernelspace):
        alarm = kernelspace.arguments().alarm

        kernelspace.add(Statement("*arg1 = %s.getRemainingTicks()" %(
            alarm.impl.name
        )))

        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.task_desc(userspace.calling_task)])

    def CancelAlarm(self, abb, userspace, kernelspace):
        alarm = kernelspace.arguments().alarm

        self.call(kernelspace, "%s.setArmed" % alarm.impl.name,
                           "void", ["false"])
        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.task_desc(userspace.calling_task)])

    def GetResource(self, abb, userspace, kernelspace):
        res = kernelspace.arguments().resource.impl

        if res.static_priority > userspace.calling_task.priority:
            res.prev_priority = userspace.calling_task.priority
            userspace.calling_task.priority = res.static_priority

        self.call(kernelspace,
                           "scheduler_["+str(userspace.calling_task.cpu_id)+"].GetResource_impl",
                           "void",
                           [self.task_desc(userspace.calling_task),
                            str(userspace.calling_task.priority)])

        kernelspace.add(Comment("Dispatch directly back to Userland"))
        self.call(kernelspace, "Dispatcher::ResumeToTask",
                           "void",
                           [self.task_desc(userspace.calling_task)])

    def ReleaseResource(self, abb, userspace, kernelspace):
        res = kernelspace.arguments().resource.impl

        if res.static_priority == userspace.calling_task.priority:
            userspace.calling_task.priority = res.prev_priority
            res.prev_priority = None

        self.call(kernelspace,
                           "scheduler_["+str(userspace.calling_task.cpu_id)+"].ReleaseResource_impl",
                           "void",
                           [self.task_desc(userspace.calling_task),
                            str(userspace.calling_task.priority)])

    # Interrupt Handling
    def disable_irq(self, block, abb):
        self.arch_rules.disable_irq(block)

    def enable_irq(self, block, abb):
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
        alarm_list = [alarm for v, alarm in self.ara_graph.instances.get(Alarm)]

        if self.alarm_filter:
            if any(self.alarm_filter(x) for x in alarm_list):
                self.subsystem_enabled = True
        else:
            if len(alarm_list) > 0:
                self.subsystem_enabled = True

    def increase_counters(self, snippet, args):
        ret = []

        for v, counter in self.ara_graph.instances.get(Counter):
            # Softcounters are ignored by the hardware interrupt
            if counter.softcounter:
                continue
            # Ignore all counters, that have no alarm attached, which
            # is actually implemented

            if self.alarm_filter:
                if all(self.alarm_filter(x) is False for x in counter.alarms):
                    continue
            ret += self.expand_snippet("increase_counter",
                                       name = counter.impl.name,
                                       cpuid = counter.cpu_id)
        return ret


    def generate_check_alarm(self, alarm, is_isr, cpuid = None):
        ret = ""
        callback_name = "AUTOSAR_ALARMCB_%s" % (alarm.name)
        has_callback = self.ara_graph.cfg.contains_function_by_name(callback_name)

        if cpuid == None:
            # CPUID is needed for Counter::tick()
            ret += self.expand_snippet("if_alarm_cpuid", alarm=alarm.impl.name, cpuid=alarm.cpu_id) + "\n"
        else:
            # softcounter syscall dont need to check cpuid
            ret += self.expand_snippet("if_alarm", alarm=alarm.impl.name) + "\n"

        # This alarm has an callback
        if has_callback:
            # Add a Declaration
            decl = FunctionDeclaration(callback_name, extern_c = True)
            self.generator.source_file.function_manager.add(decl)
            ret += self.expand_snippet("alarm_alarmcallback", callback = callback_name) + "\n"

        if alarm.impl.event != None:
            ret += "scheduler_[%d].tlist.set_events(%d, %d);\n"% (
                alarm.impl.task.cpu_id,
                alarm.impl.task.impl.task_id,
                alarm.impl.event.index,
            )
        else:
            ret += "scheduler_[%d].SetReady_impl(%s);\n"% (
                alarm.impl.task.cpu_id,
                self.rules.task_desc(alarm.impl.task)
            )

        if alarm.cpu_id != alarm.impl.task.cpu_id:
            ret += f"Machine::trigger_interrupt({self.generator.arch_rules.IPI_SIG}, {alarm.impl.task.cpu_id}, 0);\n"
        else:
            ret += f"scheduler_[{alarm.impl.task.cpu_id}].Schedule_impl(/* from_interrupt */ {str(is_isr).lower()});\n"

        ret += self.expand_snippet("endif_alarm", alarm=alarm.impl.name) + "\n"

        return ret

    def generate_check_alarms(self, snippet, args):
        ret = []

        for v, alarm in self.ara_graph.instances.get(Alarm):
            if alarm.impl.counter.softcounter:
                continue
            # assume this is expanded only in ISR Counter::tick()
            ret += [self.generate_check_alarm(alarm, True)]

        return ret
