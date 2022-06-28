from .os_util import syscall, Arg, set_next_abb, connect_from_here, find_instance_node
from .os_base import OSBase, OSState, CPUList, CPU, ControlInstance, TaskStatus, ControlContext, CrossCoreAction, ExecState, CPUBounded
from ara.util import get_logger
from ara.graph import CallPath, SyscallCategory, SigType, single_check, edge_types

import graph_tool
import html

from collections import defaultdict
from copy import copy
from dataclasses import dataclass, field
from enum import IntEnum
from itertools import chain
from typing import Any, List, Tuple

import pyllco

TASK_PREFIX = "AUTOSAR_TASK_"
ALARM_PREFIX = "AUTOSAR_ALARM_"
RESOURCE_PREFIX = "AUTOSAR_RESOURCE_"
SPINLOCK_PREFIX = "AUTOSAR_SPINLOCK_"

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
    have = 1 << 1
    trigger = 1 << 2
    activate = 1 << 3
    chain = 1 << 4
    nestable = 1 << 5
    terminate = 1 << 6
    get = 1 << 7
    release = 1 << 8
    sete = 1 << 9
    wait = 1 << 10


@dataclass(eq=False)
class AUTOSARInstance(CPUBounded):
    name: str

    def __eq__(self, other):
        # the name of an arbitrary AUTOSAR instance must be unique
        return self.name == other.name

    def __hash__(self):
        # the name of an arbitrary AUTOSAR instance must be unique
        return hash(self.__class__.__name__ + self.name)

    def __repr__(self):
        return self.name


@dataclass
class TaskGroup(AUTOSARInstance):
    promises: dict


class IRQStatus(AUTOSARInstance):
    pass


class OSIRQStatus(AUTOSARInstance):
    pass


@dataclass(repr=False)
class Task(AUTOSARInstance, ControlInstance):
    priority: int
    activation: Any
    autostart: bool
    schedule: Any

    def __hash__(self):
        return AUTOSARInstance.__hash__(self)

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


@dataclass
class TaskContext(ControlContext):
    dyn_prio: List[int]
    received_events: int = 0
    waited_events: int = 0

    def __hash__(self):
        return hash(("TaskContext",
                     self.status, self.abb, self.call_path,
                     tuple(self.dyn_prio),
                     self.received_events,
                     self.waited_events))

    def __copy__(self):
        """Make a deep copy."""
        return TaskContext(status=self.status,
                           abb=self.abb,
                           call_path=copy(self.call_path),
                           dyn_prio=[x for x in self.dyn_prio],
                           received_events=self.received_events,
                           waited_events=self.waited_events)


@dataclass(frozen=True)
class Spinlock:
    name: str


@dataclass
class SpinlockContext:
    is_spinning: bool = False
    held_by: Any = None
    wait_for: List[int] = field(default_factory=list)  # list of cpu_ids

    def __hash__(self):
        return hash(("SpinlockContext",
                     self.is_spinning,
                     tuple(self.wait_for)))

    def __copy__(self):
        """Make a deep copy."""
        return SpinlockContext(is_spinning=self.is_spinning,
                               held_by=self.held_by,
                               wait_for=[x for x in self.wait_for])


@dataclass
class Counter(AUTOSARInstance):
    mincycle: int
    maxallowedvalue: int
    ticksperbase: int
    secondspertick: int = 1


@dataclass(eq=False)
class Alarm(AUTOSARInstance):
    autostart: bool = False
    cycletime: int = 0
    alarmtime: int = 0


@dataclass(unsafe_hash=True)
class AlarmContext:
    increment: int
    cycle: int
    active: bool


@dataclass(repr=False)
class ISR(AUTOSARInstance, ControlInstance):
    priority: int
    category: int

    def __hash__(self):
        return AUTOSARInstance.__hash__(self)


@dataclass(unsafe_hash=True)
class ISRContext(ControlContext):
    dyn_prio: Tuple[int]

    def __copy__(self):
        """Make a deep copy."""
        return ISRContext(status=self.status,
                          abb=self.abb,
                          call_path=copy(self.call_path),
                          dyn_prio=(self.dyn_prio[0],))


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
    def get_cpu_local_contexts(context, cpu_id, instances):
        local_contexts = []
        for inst, ctx in context.items():
            if getattr(inst, "cpu_id", None) == cpu_id:
                local_contexts.append((inst, ctx))
            # weird case of locks for one core
            if isinstance(inst, Spinlock):
                cpus = AUTOSAR.get_cpus_of_spinlock(inst, instances)
                if len(cpus) == 1:
                    local_contexts.append((inst, ctx))
        return dict(local_contexts)

    @staticmethod
    def get_global_contexts(context, instances):
        local_contexts = []
        for inst, ctx in context.items():
            # weird case of locks for one core
            if isinstance(inst, Spinlock):
                cpus = AUTOSAR.get_cpus_of_spinlock(inst, instances)
                if len(cpus) == 1:
                    continue
            if not hasattr(inst, "cpu_id"):
                local_contexts.append((inst, ctx))
        return dict(local_contexts)

    @staticmethod
    def _irq_status_key(cpu_id):
        return IRQStatus(name="AUTOSAR_IRQ_STATUS_" + str(cpu_id),
                         cpu_id=cpu_id)

    @staticmethod
    def _os_irq_status_key(cpu_id):
        return OSIRQStatus(name="AUTOSAR_OSIRQ_STATUS_" + str(cpu_id),
                           cpu_id=cpu_id)

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
        cpu_map = {}
        for v, obj in instances.get(Task):
            if obj.cpu_id not in cpu_map:
                cpu_map[obj.cpu_id] = []
            if obj.autostart:
                cpu_map[obj.cpu_id].append((v, obj))
        for v, obj in chain(instances.get(Alarm), instances.get(ISR)):
            if obj.cpu_id not in cpu_map:
                cpu_map[obj.cpu_id] = []

        # construct actual CPUs
        cpus = []
        running_tasks = []
        irq_status = {}
        os_irq_status = {}
        for cpu_id, tasks in cpu_map.items():
            if len(tasks) == 0:
                # we have the CPU but no task that can be scheduled
                cpus.append(CPU(id=cpu_id,
                                irq_on=True,
                                control_instance=None,
                                abb=None,
                                call_path=CallPath(),
                                exec_state=ExecState.idle,
                                analysis_context=None))
                logger.debug(f"Initial: CPU {cpu_id} idles.")
            else:
                prio_vert, prio_task = max(tasks, key=lambda t: t[1].priority)
                entry_abb = cfg.get_entry_abb(prio_task.function)
                cpus.append(CPU(id=cpu_id,
                                irq_on=True,
                                control_instance=prio_vert,
                                abb=entry_abb,
                                call_path=CallPath(),
                                exec_state=ExecState.from_abbtype(cfg.vp.type[entry_abb]),
                                analysis_context=None))
                running_tasks.append(prio_task)
                logger.debug(f"Initial: Choose {instances.vp.obj[instances.vertex(prio_vert)]} for CPU {cpu_id}.")
            irq_status[cpu_id] = 0
            os_irq_status[cpu_id] = 0

        state = OSState(cpus=CPUList(cpus), instances=instances, cfg=cfg)

        # give initial running context
        max_prio = 0
        for _, obj in instances.get(Task):
            prio = 2 * obj.priority
            max_prio = max(max_prio, prio)
            status = TaskStatus.suspended
            if obj.autostart:
                status = TaskStatus.ready
            state.context[obj] = TaskContext(status=status,
                                             abb=cfg.get_entry_abb(obj.function),
                                             call_path=CallPath(),
                                             dyn_prio=[prio])

        for _, obj in instances.get(ISR):
            state.context[obj] = ISRContext(status=TaskStatus.suspended,
                                            abb=cfg.get_entry_abb(obj.function),
                                            call_path=CallPath(),
                                            dyn_prio=(max_prio + obj.priority,))

        for task in running_tasks:
            ctx = state.context[task]
            ctx.status = TaskStatus.running
            ctx.abb = None
            ctx.call_path = CallPath()

        for _, alarm in instances.get(Alarm):
            if alarm.autostart:
                state.context[alarm] = AlarmContext(
                        active=True,
                        cycle=alarm.cycletime,
                        increment=alarm.alarmtime
                )

        for _, spinlock in instances.get(Spinlock):
            state.context[spinlock] = SpinlockContext()

        # special context objects for os specific state
        for cpu_id, value in irq_status.items():
            state.context[AUTOSAR._irq_status_key(cpu_id)] = value
        for cpu_id, value in os_irq_status.items():
            state.context[AUTOSAR._os_irq_status_key(cpu_id)] = value

        return state

    @staticmethod
    def _get_taskgroup_for_task(instances, task_v):
        have = edge_types(instances, instances.ep.type, InstanceEdge.have)
        return instances.vertex(single_check(have.vertex(task_v).in_neighbors()))

    @staticmethod
    def _get_all_tasks_of_taskgroup(instances, task_group):
        have = edge_types(instances, instances.ep.type, InstanceEdge.have)
        return frozenset([instances.vertex(x) for x in have.vertex(task_group).out_neighbors()])

    @staticmethod
    def handle_irq(graph, state, cpu_id, irq):
        # we handle alarms only
        instances = state.instances
        vertex = instances.vertex(irq)
        obj = instances.vp.obj[vertex]

        activates = edge_types(instances, instances.ep.type, InstanceEdge.activate)
        event_tgt = edge_types(instances, instances.ep.type, InstanceEdge.have)

        if obj.cpu_id != cpu_id:
            # false CPU
            return

        if isinstance(obj, Alarm):
            # do not trigger alarms, if an interrupt is handled
            if isinstance(state.cur_control_inst(cpu_id), ISR):
                return
            # the current control instance must be a task

            alarm_ctx = state.context.get(obj, False)
            # TODO interarrival times
            if alarm_ctx and alarm_ctx.active:
                acty_vertex = single_check(activates.vertex(vertex).out_neighbors())
                acty = instances.vp.obj[acty_vertex]
                if isinstance(acty, Task):
                    # do not trigger alarms, if in handling task or taskgroup
                    if acty.cpu_id == cpu_id:
                        ctl_inst = state.cpus[cpu_id].control_instance
                        if ctl_inst is not None:
                            all_tasks = AUTOSAR._get_all_tasks_of_taskgroup(instances, AUTOSAR._get_taskgroup_for_task(instances, ctl_inst))
                            if acty_vertex in all_tasks:
                                return
                    logger.debug(f"Alarm {obj.name} activates {acty.name}.")
                    new_state = state.copy()
                    return AUTOSAR.ActivateTask(new_state, cpu_id, acty)
                elif isinstance(acty, Event):
                    logger.debug(f"Alarm {obj.name} sets {acty.name}.")
                    new_state = state.copy()
                    for t in event_tgt.vertex(acty_vertex).in_neighbors():
                        task = instances.vp.obj[instances.vertex(t)]
                        new_state = AUTOSAR.SetEvent(new_state, cpu_id, task,
                                                     acty.index)
                    return new_state
                else:
                    assert False, f"Edge to false object {acty}"
            return None
        elif isinstance(obj, ISR):
            # do not trigger same interrupt again
            if state.cur_control_inst(cpu_id) == obj:
                return
            logger.debug(f"Interrupt: Activate {obj.name}")
            new_state = state.copy()
            new_state.context[obj].status = TaskStatus.ready
            return new_state

        raise NotImplementedError

    @staticmethod
    def handle_exit(graph, state, cpu_id):
        # handle only IRQs
        isr = state.cur_control_inst(cpu_id)
        if isinstance(isr, ISR):
            # an ISR exit is like a TerminateTask
            new_state = state.copy()
            new_state.context[isr] = ISRContext(status=TaskStatus.suspended,
                                                abb=state.cfg.get_entry_abb(isr.function),
                                                call_path=CallPath(),
                                                dyn_prio=tuple(state.context[isr].dyn_prio))
            return [new_state]
        return []

    @staticmethod
    def get_interrupts(instances):
        return [v for v, _ in chain(instances.get(Alarm), instances.get(ISR))]

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
            if obj.cpu_id in cpus and state.context[obj].status in [TaskStatus.running, TaskStatus.ready]:
                cpu_map[obj.cpu_id].append((v, state.context[obj]))

        # update cpus
        for cpu in filter(lambda cpu: cpu.id in cpus, state.cpus):
            # the busy waiting state does never change
            if cpu.exec_state == ExecState.waiting:
                continue

            if not (cpu.id in cpu_map and len(cpu_map[cpu.id]) != 0):
                # idle state
                new_vertex = None
                new_ctx = None
                new_label = "Idle state"
            else:
                new_vertex, new_ctx = max(cpu_map[cpu.id],
                                          key=lambda t: t[1].dyn_prio[-1])
                new_vertex = state.instances.vertex(new_vertex)
                new_label = state.instances.vp.label[new_vertex]

            # not coming from idle
            if cpu.control_instance:
                old_vertex = state.instances.vertex(cpu.control_instance)
                old_task = state.instances.vp.obj[old_vertex]
                old_label = state.instances.vp.label[old_vertex]
            else:
                old_vertex = None
                old_task = None
                old_label = "Idle state"

            logger.debug(f"Schedule on CPU {cpu.id}: "
                         f"From {old_label} "
                         f"to {new_label}")

            # handle non preemptible tasks
            if (not isinstance(new_ctx, ISRContext)) and \
               isinstance(old_task, Task) and (not old_task.schedule) \
               and state.context[old_task].status == TaskStatus.running:
                # do not schedule on this CPU
                logger.debug("Do not schedule: Non preemptible task")
                continue

            # shortcut for same task
            if new_vertex == old_vertex:
                old_abb = cpu.abb
                new_abb = None if new_ctx is None else new_ctx.abb
                if old_abb == new_abb:
                    logger.debug("Skip schedule, since the task is the same.")
                    continue

            # write old values back to instance only if running or blocked
            if old_vertex:
                old_ctx = state.context[old_task]
                if old_ctx.status in [TaskStatus.running, TaskStatus.blocked]:
                    old_ctx.abb = state.cfg.vertex(cpu.abb)
                    old_ctx.call_path = cpu.call_path
                if old_ctx.status == TaskStatus.running:
                    old_ctx.status = TaskStatus.ready

            # load new values
            if new_vertex:
                cpu.abb = state.cfg.vertex(new_ctx.abb)
                cpu.call_path = new_ctx.call_path
                new_ctx.status = TaskStatus.running
                # "reset" context values, they are irrelevant now
                new_ctx.abb = None
                new_ctx.call_path = CallPath()

                cpu.control_instance = state.instances.vertex(new_vertex)
                cpu.exec_state = ExecState.from_abbtype(state.cfg.vp.type[cpu.abb])
            else:
                cpu.abb = None
                cpu.call_path = CallPath()
                cpu.control_instance = None
                cpu.exec_state = ExecState.idle

    @staticmethod
    def check_cpu(state, cpu_id):
        """Check, if cpu_id is supported in state.

        Raise a CrossCoreAction otherwise
        """
        cpu_ids = set([x.id for x in state.cpus])

        if cpu_id not in cpu_ids:
            raise CrossCoreAction(set([cpu_id]))

    @staticmethod
    def ActivateTask(state, cpu_id, task):
        assert(isinstance(task, Task))
        logger.debug(f"Setting Task {task} ready.")

        AUTOSAR.check_cpu(state, task.cpu_id)
        ctx = state.context[task]
        if ctx.status is not TaskStatus.running:
            if ctx.status is TaskStatus.suspended:
                ctx.abb = state.cfg.get_entry_abb(task.function)
            ctx.status = TaskStatus.ready
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("task", ty=Task, hint=SigType.instance),))
    def AUTOSAR_ActivateTask(cfg, state, cpu_id, args, va):
        AUTOSAR.ActivateTask(state, cpu_id, args.task)
        t = find_instance_node(state.instances, args.task)
        connect_from_here(state, cpu_id, t, "ActivateTask",
                          ty=InstanceEdge.activate)
        return state

    @syscall
    def AUTOSAR_AdvanceCounter(cfg, abb, state):
        pass

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("alarm", ty=Alarm, hint=SigType.instance),))
    def AUTOSAR_CancelAlarm(cfg, state, cpu_id, args, va):
        assert(isinstance(args.alarm, Alarm))
        if args.alarm in state.context:
            state.context[args.alarm].active = False

        a = find_instance_node(state.instances, args.alarm)
        connect_from_here(state, cpu_id, a, "CancelAlarm",
                          ty=InstanceEdge.terminate)

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("task", ty=Task, hint=SigType.instance),))
    def AUTOSAR_ChainTask(cfg, state, cpu_id, args, va):
        AUTOSAR.check_cpu(state, args.task.cpu_id)

        cur_task = state.cur_control_inst(cpu_id)
        assert isinstance(cur_task, Task), "ChainTask must be called in a task"

        state = AUTOSAR.TerminateTask(state, cpu_id)
        state = AUTOSAR.ActivateTask(state, cpu_id, args.task)

        t = find_instance_node(state.instances, args.task)
        connect_from_here(state, cpu_id, t, "ChainTask",
                          ty=InstanceEdge.chain)

        return state

    @syscall
    def AUTOSAR_CheckAlarm(cfg, abb, state):
        pass

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("event_mask"),))
    def AUTOSAR_ClearEvent(cfg, state, cpu_id, args, va):
        assert(isinstance(args.event_mask, int))
        cur_ctx = state.cur_context(cpu_id)
        cur_ctx.received_events &= ~args.event_mask

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("task_id", ty=Task, hint=SigType.instance),
                        Arg("event", hint=SigType.symbol)))
    def AUTOSAR_GetEvent(cfg, state, cpu_id, args, va):
        # the syscall does not affect the system state at all
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=tuple())
    def AUTOSAR_DisableAllInterrupts(cfg, state, cpu_id, args, va):
        state.cpus[cpu_id].irq_on = False
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=tuple())
    def AUTOSAR_EnableAllInterrupts(cfg, state, cpu_id, args, va):
        state.cpus[cpu_id].irq_on = True
        return state

    @syscall
    def AUTOSAR_GetAlarm(cfg, abb, state):
        pass

    @staticmethod
    def get_cpus_of_spinlock(spinlock, instances):
        needed_cpus = set()
        lock = instances.get_node(spinlock)
        filt = graph_tool.GraphView(
            instances,
            efilt=instances.ep.type.fa == int(InstanceEdge.have)
        )
        for task in filt.vertex(lock).in_neighbors():
            needed_cpus.add(filt.vp.obj[task].cpu_id)
        return needed_cpus

    @staticmethod
    def check_spinlock_cpus(state, spinlock):
        available_cpus = set([cpu.id for cpu in state.cpus])
        needed_cpus = AUTOSAR.get_cpus_of_spinlock(spinlock, state.instances)

        if needed_cpus > available_cpus:
            raise CrossCoreAction(needed_cpus - available_cpus)

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("spinlock", ty=Spinlock, hint=SigType.instance),),
             custom_control_flow=True)
    def AUTOSAR_GetSpinlock(cfg, state, cpu_id, args, va):
        assert(isinstance(args.spinlock, Spinlock))
        AUTOSAR.check_spinlock_cpus(state, args.spinlock)

        lock_ctx = state.context[args.spinlock]
        if lock_ctx.is_spinning:
            logger.info("GL by %s, but lock is on hold: %s",
                         state.cur_control_inst(cpu_id),lock_ctx)
            # active wait in this state
            lock_ctx.wait_for.append(cpu_id)
            state.cpus[cpu_id].exec_state = ExecState.waiting
        else:
            # just go the the next block but set the lock
            lock_ctx.is_spinning = True
            lock_ctx.held_by = state.cur_control_inst(cpu_id)
            set_next_abb(state, cpu_id)
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("spinlock", ty=Spinlock, hint=SigType.instance),),
             custom_control_flow=True)
    def AUTOSAR_ReleaseSpinlock(cfg, state, cpu_id, args, va):
        assert(isinstance(args.spinlock, Spinlock))
        AUTOSAR.check_spinlock_cpus(state, args.spinlock)

        lock_ctx = state.context[args.spinlock]

        # local backup
        wait_for = lock_ctx.wait_for
        lock_ctx.wait_for = []
        lock_ctx.is_spinning = False
        lock_ctx.held_by = None

        # the current CPU just follows the control flow
        set_next_abb(state, cpu_id)

        # wakeup one other CPUs, if they are waiting
        new_states = []
        if len(wait_for) > 0:
            # create a new state for every cpu to wakeup
            for wait_cpu in wait_for:
                new_state = state.copy()
                set_next_abb(new_state, wait_cpu)
                new_states.append(new_state)
        else:
            return state

        return new_states

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("resource", ty=Resource, hint=SigType.instance),))
    def AUTOSAR_GetResource(cfg, state, cpu_id, args, va):
        assert(isinstance(args.resource, Resource))
        # get correct dyn_prio
        res_vertex = state.instances.get_node(args.resource)
        dyn_prio = max([state.instances.vp.obj[x].priority for x in res_vertex.in_neighbors()]) * 2 + 1
        state.cur_context(cpu_id).dyn_prio.append(dyn_prio)

        connect_from_here(state, cpu_id, res_vertex, "GetResource",
                          ty=InstanceEdge.get)

        logger.debug(f"Set {state.instances.vp.label[state.cpus[cpu_id].control_instance]} to the dynamic priority {dyn_prio}.")
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("resource", ty=Resource, hint=SigType.instance),))
    def AUTOSAR_ReleaseResource(cfg, state, cpu_id, args, va):
        state.cur_context(cpu_id).dyn_prio.pop()
        if state.cur_context(cpu_id).dyn_prio:
            dyn_prio = state.cur_context(cpu_id).dyn_prio[-1]
            logger.debug(f"Set {state.instances.vp.label[state.cpus[cpu_id].control_instance]} back to priority {dyn_prio}.")

        res_vertex = state.instances.get_node(args.resource)
        connect_from_here(state, cpu_id, res_vertex, "ReleaseResource",
                          ty=InstanceEdge.get)

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=tuple())
    def AUTOSAR_ResumeAllInterrupts(cfg, state, cpu_id, args, va):
        state.context[AUTOSAR._irq_status_key(cpu_id)] -= 1
        if state.context[AUTOSAR._irq_status_key(cpu_id)] == 0:
            state.cpus[cpu_id].irq_on = True
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=tuple())
    def AUTOSAR_ResumeOSInterrupts(cfg, state, cpu_id, args, va):
        state.context[AUTOSAR._os_irq_status_key(cpu_id)] -= 1
        return state

    @staticmethod
    def connect_events(state, cpu_id, event_mask, label, ty):
        for v, event in state.instances.get(Event):
            if (event.index & event_mask) == event.index:
                connect_from_here(state, cpu_id, v, label, ty=ty)

    @staticmethod
    def SetEvent(state, cpu_id, task, event_mask):
        AUTOSAR.check_cpu(state, task.cpu_id)
        task_ctx = state.context[task]
        if task_ctx.status == TaskStatus.blocked and \
           event_mask & task_ctx.waited_events != 0:
            logger.debug(f"Unblock Task {task.name}")
            # this task already waits for this event
            task_ctx.status = TaskStatus.ready
            task_ctx.waited_events = 0

        if task_ctx.status != TaskStatus.suspended:
            task_ctx.received_events |= event_mask

        AUTOSAR.connect_events(state, cpu_id, event_mask, "SetEvent",
                               InstanceEdge.sete)

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("task", ty=Task, hint=SigType.instance),
                        Arg("event_mask")))
    def AUTOSAR_SetEvent(cfg, state, cpu_id, args, va):
        assert(isinstance(args.task, Task))
        assert(isinstance(args.event_mask, int))
        return AUTOSAR.SetEvent(state, cpu_id, args.task, args.event_mask)

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

    @syscall(categories={SyscallCategory.comm},
             signature=tuple())
    def AUTOSAR_SuspendAllInterrupts(cfg, state, cpu_id, args, va):
        state.context[AUTOSAR._irq_status_key(cpu_id)] += 1
        state.cpus[cpu_id].irq_on = False
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=tuple())
    def AUTOSAR_SuspendOSInterrupts(cfg, state, cpu_id, args, va):
        state.context[AUTOSAR._os_irq_status_key(cpu_id)] += 1
        return state

    @staticmethod
    def TerminateTask(state, cpu_id):
        cur_task = state.cur_control_inst(cpu_id)
        assert isinstance(cur_task, Task), "TerminateTask must be called in a task"

        state.context[cur_task] = TaskContext(status=TaskStatus.suspended,
                                              abb=state.cfg.get_entry_abb(cur_task.function),
                                              call_path=CallPath(),
                                              dyn_prio=[2*cur_task.priority])

        logger.debug(f"Terminate Task {cur_task.name}.")

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=tuple(),
             custom_control_flow=True)
    def AUTOSAR_TerminateTask(cfg, state, cpu_id, args, va):
        AUTOSAR.TerminateTask(state, cpu_id)
        cur = state.cpus[cpu_id].control_instance
        connect_from_here(state, cpu_id, cur, "TerminateTask",
                          ty=InstanceEdge.terminate)
        return state

    @syscall(categories={SyscallCategory.comm},
             signature=(Arg("event_mask"),))
    def AUTOSAR_WaitEvent(cfg, state, cpu_id, args, va):
        assert(isinstance(args.event_mask, int))
        cur_ctx = state.cur_context(cpu_id)

        if args.event_mask & cur_ctx.received_events == 0:
            cur_ctx.status = TaskStatus.blocked
            cur_ctx.waited_events = args.event_mask
            # release resource
            while len(state.cur_context(cpu_id).dyn_prio) > 1:
                state.cur_context(cpu_id).dyn_prio.pop()
        # else: just continue

        # the next ABB will be set _after_ this call. However, since this task
        # is blocked this isn't a problem.

        AUTOSAR.connect_events(state, cpu_id, args.event_mask, "WaitEvent",
                               InstanceEdge.wait)

        return state

    @syscall(categories={SyscallCategory.comm},
             signature=tuple())
    def ShutdownMachine(cfg, state, cpu_id, args, va):
        """Special handling for ShutdownMachine.

        Actually, this is not an AUTOSAR syscall. However, a machine shutdown
        prevents the system from executing further, so continue the analysis
        beyond this point is meaningless.
        """
        # just return nothing. The system terminates here.
        return []
