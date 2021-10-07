from .os_util import syscall, Arg, set_next_abb
from .os_base import OSBase, OSState, CPU, ControlInstance, TaskStatus, ControlContext, CrossCoreAction
from ara.util import get_logger
from ara.graph import CallPath, SyscallCategory, SigType, single_check

import graph_tool
import html

from typing import Any

from dataclasses import dataclass

from enum import IntEnum
from collections import defaultdict

import pyllco

TASK_PREFIX = "AUTOSAR_TASK_"
ALARM_PREFIX = "AUTOSAR_ALARM_"
RESOURCE_PREFIX = "AUTOSAR_RESOURCE_"

logger = get_logger("AUTOSAR")


class SyscallInfo:
    def __init__(self, name, abb, cpu):
        self.name = name
        self.abb = abb
        self.cpu = cpu
        self.multi_ret = False

    def set_multi_ret(self):
        self.multi_ret = True


class InstanceEdge(IntEnum):
    have = 1
    trigger = 2
    activate = 3


@dataclass(eq=False)
class AUTOSARInstance:
    name: str
    cpu_id: int

    def __eq__(self, other):
        # the name of an arbitrary AUTOSAR instance must be unique
        return self.name == other.name

    def __hash__(self):
        # the name of an arbitrary AUTOSAR instance must be unique
        return hash(self.__class__.__name__ + self.name)


@dataclass
class TaskGroup(AUTOSARInstance):
    name: str
    promises: dict


@dataclass
class Task(ControlInstance, AUTOSARInstance):
    function: graph_tool.Vertex
    priority: int
    activation: Any
    autostart: bool
    schedule: Any

    def __repr__(self):
        return self.name

    def __hash__(self):
        # the name of a Task must be unique
        return hash("TASK" + self.name)

    def as_dot(self):
        wanted_attrs = ["name", "autostart", "priority", "cpu_id"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                 for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#6fbf87",
            "style": "filled",
            "sublabel": sublabel
        }


@dataclass(unsafe_hash=True)
class TaskContext(ControlContext):
    dyn_prio: int
    received_events: int = 0


@dataclass
class Counter(AUTOSARInstance):
    mincycle: int
    maxallowedvalue: int
    ticksperbase: int
    secondspertick: int


@dataclass(eq=False)
class Alarm(AUTOSARInstance):
    pass


@dataclass(unsafe_hash=True)
class AlarmContext:
    increment: int
    cycle: int
    active: bool


class ISR:
    def __init__(self, name, cpu_id, category, priority, function, group):
        self.cpu_id = cpu_id
        self.name = name
        self.category = category
        self.priority = priority
        self.function = function
        self.group = group

    def __repr__(self):
        return self.name


@dataclass
class Event(AUTOSARInstance):
    index: int


@dataclass(eq=False)
class Resource(AUTOSARInstance):
    pass


class AUTOSAR(OSBase):
    """AUTOSAR model.

    See https://www.autosar.org/fileadmin/user_upload/standards/classic/20-11/AUTOSAR_SWS_OS.pdf
    """

    @staticmethod
    def get_special_steps():
        return ["LoadOIL"]

    @staticmethod
    def has_dynamic_instances():
        return False

    @staticmethod
    def get_initial_state(cfg, instances):
        # technically, AUTOSAR starts with a main function on every core
        # The actual startup happens via StartCore or in HW directly
        # After that, each core calls StartOS which syncs all cores and enables
        # interrupts.
        #
        # Since we know that interrupts are disabled and no syscall except
        # StartCore is possible before StartOS, we can safely skip the whole
        # startup routines up to StartOS for our analyses.
        #
        # Because of this, get_initial_state returns the state directly after
        # the (synchronized) StartOS call.

        # get cpu mapping
        cpu_map = defaultdict(list)
        for v in instances.get_controls().vertices():
            obj = instances.vp.obj[v]
            if obj.autostart:
                cpu_map[obj.cpu_id].append((v, obj))

        # construct actual CPUs
        cpus = []
        running_tasks = []
        for cpu_id, tasks in cpu_map.items():
            prio_vert, prio_task = max(tasks, key=lambda t: t[1].priority)
            entry_abb = cfg.get_entry_abb(prio_task.function)
            cpus.append(CPU(id=cpu_id,
                            irq_on=True,
                            control_instance=prio_vert,
                            abb=entry_abb,
                            call_path=CallPath(),
                            analysis_context=None))
            running_tasks.append(prio_task)
            logger.debug(f"Initial: Choose {instances.vp.obj[instances.vertex(prio_vert)]} for CPU {cpu_id}.")

        state = OSState(cpus=tuple(cpus), instances=instances, cfg=cfg)

        # give initial running context
        for v in instances.get_controls().vertices():
            obj = instances.vp.obj[v]
            state.context[obj] = TaskContext(status=TaskStatus.suspended,
                                             abb=cfg.get_entry_abb(obj.function),
                                             call_path=CallPath(),
                                             dyn_prio=2*obj.priority)
        for task in running_tasks:
            state.context[task].status = TaskStatus.running

        return state

    @staticmethod
    def init(instances):
        pass

    @staticmethod
    def get_next_timed_event(time, instances, cpu):
        """Returns the next timed event, e.g. an Alarm, that occurs after a given time."""
        event_list = []
        for v_instance in instances.vertices():
            instance = instances.vp.obj[v_instance]
            if isinstance(instance, Alarm):
                alarm = instance
                counter = alarm.counter

                if counter is not None and alarm.cpu_id == cpu:

                    # only handle autostart alarms at the moment
                    if alarm.autostart:
                        # period of the alarm in ms
                        period = alarm.cycletime * counter.secondspertick * 1000
                        alarmtime = alarm.alarmtime * counter.secondspertick * 1000

                        mod = time % period
                        if mod < alarmtime:
                            diff = alarmtime - mod
                        else:
                            diff = alarmtime + period - mod

                        event_time = time + diff
                        event_list.append((event_time, alarm))

        # sort event list to get nearest event
        event_list.sort(key=lambda x: x[0])
        if len(event_list) != 0:
            return event_list[0]
        else:
            return None, None

    @staticmethod
    def execute_event(event, state):
        """Interprets a timed event, e.g. an alarm, and creates a new state."""
        new_state = state.copy()

        if isinstance(event, Alarm):
            alarm = event
            if alarm.action == AlarmAction.ACTIVATETASK:
                if alarm.task not in new_state.activated_tasks:
                    new_state.activated_tasks.append(alarm.task)
                    AUTOSAR.schedule(new_state, new_state.cpu)

        new_state.from_event = True
        return new_state

    @staticmethod
    def handle_isr(state):
        """Handles an IRQ."""
        new_states = []
        current_isr = state.get_current_isr()
        scheduled_task = state.get_scheduled_task()
        priority = 0

        if current_isr is not None:
            priority = current_isr.priority

        # go through all ISRs in instances
        for v in state.instances.vertices():
            isr = state.instances.vp.obj[v]
            if isinstance(isr, ISR):
                if isr.cpu_id == state.cpu:
                    if (current_isr is None or isr.name != current_isr.name) and isr not in state.activated_isrs:
                        if isr.priority > priority and scheduled_task not in isr.group:
                        # if isr.priority > priority:
                            new_state = state.copy()
                            new_states.append(new_state)
                            # new_state.from_isr = True

                            # activate new isr
                            new_state.activated_isrs.append_item(isr)

                            # schedule the interrupts
                            for _list in new_state.activated_isrs.values():
                                _list.sort(key=lambda isr: isr.priority, reverse=True)

        return new_states

    @staticmethod
    def exit_isr(state):
        """Handles the end of an ISR."""
        new_state = state.copy()
        current_isr = state.get_current_isr()

        # remove isr from list of activated isrs
        new_state.activated_isrs.remove_item(current_isr)

        # reset abb of isr to the entry abb
        new_state.set_abb(current_isr.name, new_state.entry_abbs[current_isr.name])

        if new_state.get_running_abb() is None or new_state.interrupts_enabled.get_value() is None:
            return AUTOSAR.decompress_state(new_state)
        else:
            return [new_state]

    @staticmethod
    def handle_irq(graph, state, cpu_id, irq):
        # we handle alarms only
        instances = state.instances
        alarm_vertex = instances.vertex(irq)
        alarm = instances.vp.obj[alarm_vertex]
        alarm_ctx = state.context.get(alarm, False)
        # TODO interarrival times
        if alarm_ctx and alarm_ctx.active:
            activates = graph_tool.GraphView(
                    state.instances,
                    efilt=state.instances.ep.type.fa == int(InstanceEdge.activate)
            )
            task_vertex = single_check(activates.vertex(alarm_vertex).out_neighbors())
            task = state.instances.vp.obj[task_vertex]

            logger.debug(f"Alarm {alarm.name} activates {task.name}.")
            return AUTOSAR.ActivateTask(state, cpu_id, task)
        return None

    @staticmethod
    def get_interrupts(instances):
        return [v for v, _ in instances.get(Alarm)]

    @staticmethod
    def interpret(graph, state, cpu_id, categories=SyscallCategory.every):
        cfg = graph.cfg
        abb = state.cpus[cpu_id].abb
        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}, CPU {cpu_id}, "
                     f"ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall_function = getattr(AUTOSAR, syscall)

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.every not in categories:
            sys_cat = syscall_function.categories
            if sys_cat | categories != sys_cat:
                # do not interpret this syscall
                state = state.copy()
                set_next_abb(state, cpu_id)
                return state
        return syscall_function(graph, state, cpu_id)

    @staticmethod
    def is_inter_cpu_syscall(cfg, abb, state, cpu):
        """Checks whether the syscall has interferences with other cpus."""
        syscall = cfg.get_syscall_name(abb)

        if "ActivateTask" in syscall:
            # get Task argument
            scheduled_task = state.get_scheduled_instance()
            # unclear
            # cp = CallPath(graph=state.callgraphs[scheduled_task.name], node=state.call_nodes[scheduled_task.name].get_value())
            # arg = state.cfg.vp.arguments[abb][0].get(call_path=cp, raw=True)
            cp = state.call_path
            task_name = get_argument(cfg, abb, cp, 0, ty=pyllco.GlobalVariable).get_name()

            # find task with same name as 'arg' in instance graph
            task = None
            for v in state.instances.vertices():
                task = state.instances.vp.obj[v]
                if isinstance(task, Task):
                    if task.name in task_name:
                        break

            # check if found task runs on different cpu
            if task.cpu_id != cpu:
                return True

        return False

    @staticmethod
    def schedule(state, cpus=None):
        if cpus is None:
            cpus = [cpu.id for cpu in state.cpus]

        logger.debug(f"Scheduling state {state} on CPUs: {cpus}")

        # get cpu mapping
        cpu_map = defaultdict(list)
        for v in state.instances.get_controls().vertices():
            obj = state.instances.vp.obj[v]
            if state.context[obj].status in [TaskStatus.running, TaskStatus.ready]:
                cpu_map[obj.cpu_id].append((v, state.context[obj]))

        # update cpus
        for cpu in filter(lambda cpu: cpu.id in cpus, state.cpus):
            if not (cpu.id in cpu_map and len(cpu_map[cpu.id]) != 0):
                # idle state
                new_vertex = None
                new_ctx = None
                new_label = "Idle state"
            else:
                new_vertex, new_ctx = max(cpu_map[cpu.id],
                                          key=lambda t: t[1].dyn_prio)
                new_vertex = state.instances.vertex(new_vertex)
                new_label = state.instances.vp.label[new_vertex]

            # not coming from idle
            if cpu.control_instance:
                old_vertex = state.instances.vertex(cpu.control_instance)
                old_task = state.instances.vp.obj[old_vertex]
                old_label = state.instances.vp.label[old_vertex]
            else:
                old_vertex = None
                old_label = "Idle state"

            logger.debug(f"Schedule on CPU {cpu.id}: "
                         f"From {old_label} "
                         f"to {new_label}")

            # shortcut for same task
            if new_vertex == old_vertex:
                continue

            # write old values back to instance
            if old_vertex:
                old_ctx = state.context[old_task]
                old_ctx.abb = state.cfg.vertex(cpu.abb)
                old_ctx.call_path = cpu.call_path
                if old_ctx.status is TaskStatus.running:
                    old_ctx.status = TaskStatus.ready

            # load new values
            if new_vertex:
                cpu.abb = state.cfg.vertex(new_ctx.abb)
                cpu.call_path = new_ctx.call_path
                new_ctx.status = TaskStatus.running

                cpu.control_instance = state.instances.vertex(new_vertex)
            else:
                cpu.abb = None
                cpu.call_path = None
                cpu.control_instance = None

    @staticmethod
    def decompress_state(state):

        def delete_key(state, key):
            del state.activated_tasks[key]
            del state.activated_isrs[key]
            del state.interrupts_enabled[key]
            for option in state.abbs.values():
                del option[key]
            for option in state.call_nodes.values():
                del option[key]


        def switch_key(state):
            # switch some random key to the id of the state, then delete the random key
            oldkey = list(state.activated_tasks.keys()).pop()
            state.set_activated_task(state.activated_tasks[oldkey])
            state.set_activated_isr(state.activated_isrs[oldkey])
            state.set_interrupts_enabled_flag(state.interrupts_enabled[oldkey])
            for option in state.abbs.values():
                option[state.key] = option[oldkey]
            for option in state.call_nodes.values():
                option[state.key] = option[oldkey]

            # delete_key(state, oldkey)

        # print(f"decompress {state}")
        # print(f"abbs: {state.abbs}")
        # print(f"activated tasks: {state.activated_tasks}")
        new_states = []
        task_names = []
        for key, activated_tasks_list in state.activated_tasks.items():
            activated_isrs_list = state.activated_isrs[key]
            if len(activated_tasks_list) > 0:
                task = activated_tasks_list[0]
                if len(activated_isrs_list) > 0:
                    task = activated_isrs_list[0]
                if task.name not in task_names:
                    task_names.append(task.name)

        # return the original state if no tasks are activated, e.g. idle state
        if len(task_names) == 0:
            new_states.append(state)

        # print(f"tasknames: {task_names}")

        for taskname in task_names:
            interstates = []
            interstate = state.copy()

            # remove every tasklist that has a different running task as taskname
            for key, activated_tasks_list in state.activated_tasks.items():
                activated_isrs_list = state.activated_isrs[key]
                if key == state.key:
                    key = interstate.key
                if taskname.startswith("AUTOSAR_ISR"):
                    if len(activated_isrs_list) == 0 or activated_isrs_list[0].name != taskname:
                        delete_key(interstate, key)
                else:
                    if len(activated_tasks_list) == 0 or activated_tasks_list[0].name != taskname or len(activated_isrs_list) > 0:
                        # remove the tasklist and everything with the same key
                        delete_key(interstate, key)


            # check if the interrupts enabled flag is unique
            if interstate.interrupts_enabled.get_value() is None:
                new_state_true = interstate.copy()
                new_state_false = interstate.copy()

                for key, flag in interstate.interrupts_enabled.items():
                    if flag:
                        if key == interstate.key:
                            key = new_state_false.key
                        delete_key(new_state_false, key)
                    else:
                        if key == interstate.key:
                            key = new_state_true.key
                        delete_key(new_state_true, key)

                interstates.append(new_state_true)
                interstates.append(new_state_false)
            else:
                interstates.append(interstate)

            # print(f"interstate {taskname}:{interstate}")

            for interstate in interstates:
                # make sure all states have self id as a key
                if interstate.key not in interstate.activated_tasks:
                    switch_key(interstate)

                # check if the running abb is unique
                if interstate.abbs[taskname].get_value() is None:
                    for key, abb in interstate.abbs[taskname].items():
                        activated_tasks_list = interstate.activated_tasks[key]
                        activated_isrs_list = interstate.activated_isrs[key]
                        interrupt_flag = interstate.interrupts_enabled[key]
                        # if len(activated_tasks_list) > 0 and activated_tasks_list[0].name == taskname or len(activated_isrs_list) > 0 and activated_isrs_list[0].name == taskname:
                        new_state = interstate.copy()
                        new_states.append(new_state)

                        new_state.set_abb(taskname, abb)
                        new_state.set_activated_task(activated_tasks_list.copy())
                        new_state.set_activated_isr(activated_isrs_list.copy())
                        new_state.set_interrupts_enabled_flag(interrupt_flag)
                        # print(f"new_state {taskname}:{new_state}")
                else:
                    new_states.append(interstate)

        return new_states


    @staticmethod
    def check_cpu(state, cpu_id):
        """Check, if cpu_id is supported in state.

        Raise a CrossCoreAction otherwise
        """
        cpu_ids = set([x.id for x in state.cpus])

        if cpu_id not in cpu_ids:
            raise CrossCoreAction

    @staticmethod
    def ActivateTask(state, cpu_id, task):
        assert(isinstance(task, Task))
        state = state.copy()

        logger.debug(f"Setting Task {task} ready.")

        AUTOSAR.check_cpu(state, task.cpu_id)
        state.context[task].status = TaskStatus.ready
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("task", ty=Task, hint=SigType.instance),))
    def AUTOSAR_ActivateTask(cfg, state, cpu_id, args, va):
        return AUTOSAR.ActivateTask(state, cpu_id, args.task)

    @syscall
    def AUTOSAR_AdvanceCounter(cfg, abb, state):
        pass

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("alarm", ty=Alarm, hint=SigType.instance),))
    def AUTOSAR_CancelAlarm(cfg, state, cpu_id, args, va):
        assert(isinstance(args.alarm, Alarm))
        state = state.copy()

        if args.alarm in state.context:
            state.context[args.alarm].active = False

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("task", ty=Task, hint=SigType.instance),))
    def AUTOSAR_ChainTask(cfg, state, cpu_id, args, va):
        state = state.copy()
        AUTOSAR.check_cpu(state, args.task.cpu_id)

        logger.debug(f"Setting Task {args.task} ready.")

        cur_task = state.cur_control_inst(cpu_id)
        assert isinstance(cur_task, Task), "ChainTask must be called in a task"

        state.context[cur_task].status = TaskStatus.suspended
        state.context[args.task].status = TaskStatus.ready

        return state

    @syscall
    def AUTOSAR_CheckAlarm(cfg, abb, state):
        pass

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("event_mask"),))
    def AUTOSAR_ClearEvent(cfg, state, cpu_id, args, va):
        assert(isinstance(args.event_mask, int))
        state = state.copy()

        cur_ctx = state.cur_context(cpu_id)
        cur_ctx.received_events &= ~args.event_mask

        return state

    @syscall
    def AUTOSAR_DisableAllInterrupts(cfg, abb, state, cpu):
        new_state = state.copy()

        new_state.set_interrupts_enabled_flag(False)

        scheduled_task = state.get_scheduled_instance()

        # advance task or isr to next abb
        new_state.set_abb(scheduled_task.name, next(cfg.vertex(abb).out_neighbors()))

        return new_state

    @syscall
    def AUTOSAR_EnableAllInterrupts(cfg, abb, state, cpu):
        new_state = state.copy()

        new_state.set_interrupts_enabled_flag(True)

        scheduled_task = state.get_scheduled_instance()

        # advance task or isr to next abb
        new_state.set_abb(scheduled_task.name, next(cfg.vertex(abb).out_neighbors()))

        return new_state

    @syscall
    def AUTOSAR_GetAlarm(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_GetEvent(cfg, abb, state):
        pass

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("resource", ty=Resource, hint=SigType.instance),))
    def AUTOSAR_GetResource(cfg, state, cpu_id, args, va):
        assert(isinstance(args.resource, Resource))
        state = state.copy()

        # get correct dyn_prio
        res_vertex = single_check(filter(lambda x: state.instances.vp.obj[x] == args.resource, state.instances.vertices()))
        dyn_prio = max([state.instances.vp.obj[x].priority for x in res_vertex.in_neighbors()]) * 2 + 1

        state.cur_context(cpu_id).dyn_prio = dyn_prio
        logger.debug(f"Set {state.instances.vp.label[state.cpus[cpu_id].control_instance]} to the dynamic priority {dyn_prio}.")
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("resource", ty=Resource, hint=SigType.instance),))
    def AUTOSAR_ReleaseResource(cfg, state, cpu_id, args, va):
        state = state.copy()
        dyn_prio = state.cur_control_inst(cpu_id).priority * 2
        state.cur_context(cpu_id).dyn_prio = dyn_prio
        logger.debug(f"Set {state.instances.vp.label[state.cpus[cpu_id].control_instance]} back to priority {dyn_prio}.")

        return state

    @syscall
    def AUTOSAR_ResumeAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_ResumeOSInterrupts(cfg, abb, state):
        pass

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("task", ty=Task, hint=SigType.instance),
                        Arg("event_mask")))
    def AUTOSAR_SetEvent(cfg, state, cpu_id, args, va):
        assert(isinstance(args.task, Task))
        assert(isinstance(args.event_mask, int))

        state = state.copy()

        task_ctx = state.context[args.task]
        if task_ctx.status == TaskStatus.blocked and \
           args.event_mask & task_ctx.received_events != 0:
            # this task already waits for this event
            task_ctx.status == TaskStatus.ready
            # clear old events on which the task has waited, set all other
            task_ctx.received_events = ~task_ctx.received_events & args.event_mask
        else:
            # just set the additional events
            task_ctx.received_events |= args.event_mask

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("alarm", ty=Alarm, hint=SigType.instance),
                        Arg("increment"),
                        Arg("cycle")))
    def AUTOSAR_SetRelAlarm(cfg, state, cpu_id, args, va):
        """
        This call starts an alarm running and sets the number of counter ticks
        that will occur before the alarm is triggered. The alarm may be
        triggered once only (if cycle is equal to zero) or repeatedly (cycle
        gives the number of counter ticks before the alarm is triggered again).
        When the alarm is triggered, the task associated with the alarm is
        activated. The alarm can activate a task, set an event or call an alarm
        callback (depending on configuration).
        The behavior when increment is zero is dependant on configuration
        as follows:
        - OSEK (default) the alarm occurs in maxallowedvalue+1 ticks of
          the counter
        - OSEK (SetRelAlarm(,0) disallowed) the alarm is not set and the
          API call returns E_OS_VALUE
        - AUTOSAR the alarm is not set and the API call returns
          E_OS_VALUE
        """
        assert(isinstance(args.increment, int))
        assert(isinstance(args.cycle, int))

        AUTOSAR.check_cpu(state, args.alarm.cpu_id)

        state = state.copy()
        state.context[args.alarm] = AlarmContext(increment=args.increment,
                                                 cycle=args.cycle,
                                                 active=True)
        return state

    @syscall
    def AUTOSAR_ShutdownOS(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_StartOS(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_SuspendAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_SuspendOSInterrupts(cfg, abb, state):
        pass

    @syscall(categories={SyscallCategory.comm},
             signature=tuple(),
             custom_control_flow=True)
    def AUTOSAR_TerminateTask(cfg, state, cpu_id, args, va):
        state = state.copy()

        cur_task = state.cur_control_inst(cpu_id)
        assert isinstance(cur_task, Task), "TerminateTask must be called in a task"

        state.context[cur_task].status = TaskStatus.suspended

        logger.debug(f"Terminate Task {cur_task.name}.")

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("event_mask"),))
    def AUTOSAR_WaitEvent(cfg, state, cpu_id, args, va):
        assert(isinstance(args.event_mask, int))
        state = state.copy()

        cur_ctx = state.cur_context(cpu_id)

        if args.event_mask & cur_ctx.received_events == 0:
            cur_ctx.status = TaskStatus.blocked
            # store event that is waited for in received_events since this
            # field is unused as long as the task is blocked
            cur_ctx.received_events = args.event_mask
            # release resource
            dyn_prio = state.cur_control_inst(cpu_id).priority * 2
            state.cur_context(cpu_id).dyn_prio = dyn_prio

        # the next ABB will be set _after_ this call. However, since this task
        # is blocked this isn't a problem.

        return state
