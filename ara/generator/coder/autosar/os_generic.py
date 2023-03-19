from ..elements import *
from ..base import BaseCoder
#from generator.analysis.Function import Function as GraphFunction
from .implementations import *
import logging

from collections import namedtuple

class GenericOS(BaseCoder):
    def __init__(self):
        super(GenericOS, self).__init__()

    def systemcall(self, abb, userspace):
        """Generate systemcall"""
        syscall_name = self.ara_graph.cfg.get_syscall_name(abb)[8:]
        abb_name = self.ara_graph.cfg.vp.name[abb]
        fn = self.ara_graph.cfg.get_function(abb)
        fn_name = self.ara_graph.cfg.vp.name[fn]
        args = self.ara_graph.cfg.vp.arguments[abb]
        if args == None:
            self._log.info("systemcall %s in %s never called", syscall_name, abb_name)
            userspace.add(Comment("never called"))

            userspace.add(Statement("debug_core << __FUNCTION__ << \" should never be called\" << endl"))
            userspace.add(Statement("AUTOSAR_ShutdownAllCores(E_NOT_OK)"))
            return
        ret_type = self.syscall_rules.AUTOSAR_SYSCALLS["AUTOSAR_"+syscall_name][0]
        if ret_type != "void":
            userspace.add(Statement("StatusType result = E_OK"))

        kernelspace = self.arch_rules.generate_kernelspace(userspace, abb, args)

        if hasattr(self.syscall_rules, syscall_name):
            f = getattr(self.syscall_rules, syscall_name)
            f(abb, userspace, kernelspace.system)
        else:
            raise NotImplementedError("Not yet supported %d", syscall_name)

        kernelspace.pre_hook.add(Statement("debug_core << __FUNCTION__ << endl"))


        if ret_type != "void":
            check_error = If ("result != E_OK")
            check_error.add(Statement("CALL_HOOK(ErrorHook, result)"))
            kernelspace.post_hook.add(check_error)

            userspace.return_statement("result")

    def generate_data_objects(self):
        """In this function, we generate all system objects which are used by OS implementation."""
        self.generate_dataobjects_task_descriptors()
        self.generate_dataobjects_counters_and_alarms()
        self.generate_dataobjects_global_ids()
        # Give the passes the chance to generate dataobjects
        #self.callback_in_valid_passes("generate_dataobjects")



    def generate_dataobjects_task_descriptors(self):
        self.generator.source_file.include("os/scheduler/task.h")

        for v, task in self.ara_graph.instances.get(Task):

            initializer = "(%d, %d, %d, %s, arch::%s)" % (
                task.impl.task_id,
                task.cpu_id,
                task.priority,
                str(task.schedule).lower(),
                task.impl.tcb_descriptor.name
            )

            desc = DataObject("const os::scheduler::Task", "OS_" + task.name + "_task",
                              initializer)
            desc.allocation_prefix = "constexpr "

            self.generator.source_file.data_manager.add(desc, namespace = ("os", "tasks"))
            task.impl.task_descriptor = desc


    def generate_counter(self, ctr):
        return DataObject("UnencodedCounter",
                             "OS_%s_counter" % (ctr.name),
                             "(%d, %d, %d)" % (ctr.maxallowedvalue,
                                               ctr.ticksperbase,
                                               ctr.mincycle))
    def generate_alarm(self, alarm, counter, task):
        if alarm.autostart:
            alarm.impl.armed = True
        else:
            alarm.impl.armed = False
        return DataObject("UnencodedAlarm",
                           "OS_%s_alarm" %( alarm.name),
                           "(&%s, %s, %s, %d, %d, %d)" % (
                                                     counter.impl.name,
                                                     task,
                                                     str(alarm.impl.armed).lower(),
                                                     alarm.alarmtime,
                                                     alarm.cycletime,
                                                     alarm.impl.alarm_id,
                           ))

    def generate_dataobjects_counters_and_alarms(self):
        self.generator.source_file.include("os/counter.h")
        self.generator.source_file.include("os/alarm.h")

        for v, ctr in self.ara_graph.instances.get(Counter):
            assert ctr.maxallowedvalue < 2**16, "At the moment the maxallowedvalue has to fit into a 16 Bit Value"

            impl = self.generate_counter(ctr)

            if impl:
                # Add and save counter Implementation
                self.generator.source_file.data_manager.add(impl, namespace = ("os",))
                ctr.impl = impl

        alarm_id = 1

        for v, alarm in self.ara_graph.instances.get(Alarm):
            edges = [e for e in v.out_edges()] + [e for e in v.in_edges()]

            for e in edges:
                label = self.ara_graph.instances.ep.label[e]
                if label == "activate":
                    t = self.ara_graph.instances.vp.obj[e.target()]
                    alarm.impl.task = t
                elif label == "set":
                    event = self.ara_graph.instances.vp.obj[e.target()]
                    alarm.impl.event = event
                else:
                    inst = self.ara_graph.instances.vp.obj[e.source()]
                    if isinstance(inst, Counter):
                         alarm.impl.counter = inst

            task = "os::tasks::" + alarm.impl.task.impl.task_descriptor.name

            alarm.impl.alarm_id = alarm_id
            alarm_id += 1

            impl = self.generate_alarm(alarm, alarm.impl.counter, task)
            if impl:
                # Add and save alarm implementation
                self.generator.source_file.data_manager.add(impl, namespace = ("os",))
                alarm.impl.name = impl.name
                alarm.impl.alarm_desc = impl

    def generate_system_code(self):
        pass

    def generate_dataobjects_global_ids(self):
        """We have to generate identifiers for every system object. This has
           to be done after the objects are allocated.

        """
        for v, task in self.ara_graph.instances.get(Task):
            # add: const TaskType subtaskname_id = OS_subtask.name_task.id
            iddesc = DataObject("const TaskType", "AUTOSAR_TASK_" + task.name,
                                static_initializer = str(task.impl.task_id),
                                extern_c = True)
            self.generator.source_file.data_manager.add(iddesc)

        for v, alarm in self.ara_graph.instances.get(Alarm):
            iddesc = DataObject("const AlarmType", "AUTOSAR_ALARM_" + alarm.name,
                                static_initializer = str(alarm.impl.alarm_id),
                                extern_c = True)
            self.generator.source_file.data_manager.add(iddesc)

        for v, res in self.ara_graph.instances.get(Resource):
            neighbors = self.ara_graph.instances.get_all_neighbors(v)
            tasks_prio = [self.ara_graph.instances.vp.obj[n].priority for n in neighbors]
            res.impl.static_priority = max(tasks_prio)+1
            iddesc = DataObject("const ResourceType", "AUTOSAR_RESOURCE_" + res.name,
                                static_initializer = str(res.impl.static_priority),
                                extern_c = True)
            self.generator.source_file.data_manager.add(iddesc)

        for v, ctr in self.ara_graph.instances.get(Counter):
            iddesc = DataObject("const CounterType", "AUTOSAR_COUNTER_" + ctr.name,
                                static_initializer = "0",
                                extern_c = True)
            self.generator.source_file.data_manager.add(iddesc)

        for v, event in self.ara_graph.instances.get(Event):

            iddesc = DataObject("const EventMaskType", "AUTOSAR_EVENT_" + event.name,
                                static_initializer = str(event.index),
                                extern_c = True)
            self.generator.source_file.data_manager.add(iddesc)

        self.generator.source_file.include("os/spinlock.h")
        for v, spinlock in self.ara_graph.instances.get(Spinlock):
            iddesc = DataObject("const SpinlockType", "AUTOSAR_SPINLOCK_" + spinlock.name,
                                static_initializer = str(spinlock.impl.id),
                                extern_c = True)
            self.generator.source_file.data_manager.add(iddesc)

            desc = DataObject("os::Spinlock", "OS_" + spinlock.name, "("+iddesc.name+")")
            self.generator.source_file.data_manager.add(desc, namespace = ("os",))
            spinlock.impl.descriptor = desc

    def generate_hooks(self):
        hooks = [("PreIdleHook",[]),("FaultDetectedHook",["DetectedFault_t","uint32_t","uint32_t"]),
                 ("StartupHook", []), ("PreTaskHook", []), ("PostTaskHook", []),
                 ("ShutdownHook", ["StatusType"]), ("ErrorHook", ["StatusType"])]
        for hook,args in hooks:
            hook_function = Function("__OS_HOOK_" + hook, "void", args)
            self.generator.source_file.function_manager.add(hook_function)
            # Cast arguments to void, to get rid of unused parameter warning
            for i in range(0, len(args)):
                hook_function.unused_parameter(i)

            # In the pre idle hook, we place the kickoff method

            if hook == "PreIdleHook":
                self.call(hook_function, "AUTOSAR_kickoff", "void", [])


            user_defined = "__OS_HOOK_DEFINED_" + hook

            if self.ara_graph.cfg.contains_function_by_name(user_defined):
                # Generate actual call, only if user had defined the hook function
                self.call(hook_function, user_defined, "void", hook_function.arguments_names())
                if hook == "PostTaskHook":
                    logging.warning("Be aware that PostTaskHooks are not properly implemented")

            if hook == "FaultDetectedHook" or hook == "ErrorHook":
                hook_function.add(Statement(f"debug_core << \"{hook} \" << arg0 << endl"))
                self.call(hook_function, "ShutdownMachine", "void", [])
                self.call(hook_function, "Machine::unreachable", "void", [])

