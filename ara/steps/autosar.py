from .os_util import syscall
from .os_base import OSBase
from ara.util import get_logger
from ara.graph.argument import CallPath

from enum import Enum

logger = get_logger("AUTOSAR")


class SyscallInfo:
    def __init__(self, name, abb, cpu):
        self.name = name
        self.abb = abb
        self.cpu = cpu
        self.multi_ret = False

    def set_multi_ret(self):
        self.multi_ret = True

class Task:
    def __init__(self, cfg, name, function, priority, activation,
                 autostart, schedule, cpu_id):
        self.cfg = cfg
        self.name = name
        self.function = function
        self.priority = priority
        self.activation = activation
        self.autostart = autostart
        self.schedule = schedule
        self.cpu_id = cpu_id
    
    def __repr__(self):
        return self.name

class Counter:
    def __init__(self, name, cpu_id, mincycle, maxallowedvalue, ticksperbase, secondspertick):
        self.cpu_id = cpu_id
        self.mincycle = mincycle
        self.maxallowedvalue = maxallowedvalue
        self.ticksperbase = ticksperbase
        self.secondspertick = secondspertick
        self.name = name

    def __repr__(self):
        return self.name

class AlarmAction(Enum):
    ACTIVATETASK = 1,
    SETEVENT = 2,
    INCREMENTCOUNTER = 3

class Alarm:
    def __init__(self, name, cpu_id, counter, autostart, action, task=None, event=None, incrementcounter=None, alarmtime=None, cycletime=None):
        self.cpu_id = cpu_id
        self.name = name
        self.counter = counter
        self.autostart = autostart
        self.action = action
        self.task = task
        self.event = event
        self.incrementcounter = incrementcounter,
        self.alarmtime = alarmtime,
        self.cycletime = cycletime
    
    def __repr__(self):
        return self.name

class ISR:
    def __init__(self, name, cpu_id, category, priority, function):
        self.cpu_id = cpu_id
        self.name = name
        self.category = category
        self.priority = priority
        self.function = function
    
    def __repr__(self):
        return self.name

class AUTOSAR(OSBase):
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)')]
    edge_properties = [('label', 'string', 'syscall name')]

    @staticmethod
    def init(instances):
        for prop in AUTOSAR.vertex_properties:
            instances.vp[prop[0]] = instances.new_vp(prop[1])
        for prop in AUTOSAR.edge_properties:
            instances.ep[prop[0]] = instances.new_ep(prop[1])

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
        priority = 0

        if current_isr is not None:
            priority = current_isr.priority
        
        # go through all ISRs in instances
        for v in state.instances.vertices():
            isr = state.instances.vp.obj[v]
            if isinstance(isr, ISR):
                if isr.cpu_id == state.cpu:
                    if (current_isr is None or isr.name != current_isr.name) and isr not in state.activated_isrs:
                        new_state = state.copy()
                        new_states.append(new_state)
                        new_state.from_isr = True

                        # activate new isr
                        new_state.activated_isrs.append(isr)

                        # schedule the interrupts
                        new_state.activated_isrs.sort(key=lambda isr: isr.priority, reverse=True)

        return new_states

    @staticmethod
    def exit_isr(state):
        """Handles the end of an ISR."""
        new_state = state.copy()
        current_isr = state.get_current_isr()

        # remove isr from list of activated isrs
        new_state.activated_isrs.remove(current_isr)

        # reset abb of isr to the entry abb
        new_state.abbs[current_isr.name] = new_state.entry_abbs[current_isr.name]

        return new_state

    @staticmethod
    def interpret(cfg, abb, state, cpu, is_global=False):
        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}")
        if is_global:
            syscall += "_global"
        return getattr(AUTOSAR, syscall)(cfg, abb, state, cpu)

    @staticmethod
    def is_inter_cpu_syscall(cfg, abb, state, cpu):
        """Checks whether the syscall has interferences with other cpus."""
        syscall = cfg.get_syscall_name(abb)

        if "ActivateTask" in syscall:
            # get Task argument
            scheduled_task = state.get_scheduled_task()
            cp = CallPath(graph=state.callgraphs[scheduled_task.name], node=state.call_nodes[scheduled_task.name])
            arg = state.cfg.vp.arguments[abb][0].get(call_path=cp, raw=True)

            # find task with same name as 'arg' in instance graph
            task = None
            for v in state.instances.vertices():
                task = state.instances.vp.obj[v]
                if isinstance(task, Task):
                    if task.name in arg.get_name():
                        break

            # check if found task runs on different cpu
            if task.cpu_id != cpu:
                return True

        return False

    @staticmethod
    def schedule(state, cpu):
        # sort actived tasks by priority
        state.activated_tasks.sort(key=lambda task: task.priority, reverse=True)

    @syscall
    def AUTOSAR_ActivateTask_global(cfg, abb, metastate, cpu):
        graph = metastate.state_graph[cpu]
        v = graph.get_vertices()[0]
        state = graph.vp.state[v]

        scheduled_task = state.get_scheduled_task()
        current_isr = state.get_current_isr()
        if current_isr is not None:
            scheduled_task = current_isr

        # get Task argument
        cp = CallPath(graph=state.callgraphs[scheduled_task.name], node=state.call_nodes[scheduled_task.name])
        arg = state.cfg.vp.arguments[abb][0].get(call_path=cp, raw=True)

        # find task with same name as 'arg' in instance graph
        task = None
        for v in state.instances.vertices():
            task = state.instances.vp.obj[v]
            if isinstance(task, Task):
                if task.name in arg.get_name():
                    break

        # find target state
        target_cpu = task.cpu_id
        t_graph = metastate.state_graph[target_cpu]
        t_vertex = t_graph.get_vertices()[0]
        target_state = t_graph.vp.state[t_vertex]

        # add found Task to list of activated tasks
        if task not in target_state.activated_tasks:
            target_state.activated_tasks.append(task)

        # advance current task to next abb
        counter = 0
        for n in cfg.vertex(abb).out_neighbors():
            state.abbs[scheduled_task.name] = n
            counter += 1
        assert(counter == 1)

        # trigger scheduling 
        AUTOSAR.schedule(target_state, task.cpu_id)

        # print("Activate Task globally: " + task.name)


    @syscall
    def AUTOSAR_ActivateTask(cfg, abb, state, cpu):
        state = state.copy()
        scheduled_task = state.get_scheduled_task()
        current_isr = state.get_current_isr()
        if current_isr is not None:
            scheduled_task = current_isr

        # get Task argument
        cp = CallPath(graph=state.callgraphs[scheduled_task.name], node=state.call_nodes[scheduled_task.name])
        arg = state.cfg.vp.arguments[abb][0].get(call_path=cp, raw=True)

        # find task with same name as 'arg' in instance graph
        task = None
        for v in state.instances.vertices():
            task = state.instances.vp.obj[v]
            if isinstance(task, Task):
                if task.name in arg.get_name():
                    break

        # add found Task to list of activated tasks
        if task not in state.activated_tasks:
            state.activated_tasks.append(task)

        # old_task = state.get_scheduled_task(task.cpu_id)

        # advance current task to next abb
        counter = 0
        for n in cfg.vertex(abb).out_neighbors():
            state.abbs[scheduled_task.name] = n
            counter += 1
        assert(counter == 1)

        # trigger scheduling 
        AUTOSAR.schedule(state, task.cpu_id)

        # set multi ret for gcfg building if the new task was scheduled
        # new_task = state.get_scheduled_task(task.cpu_id)
        # if cpu != task.cpu_id:
        #     if new_task.name == task.name:
        #         state.gcfg_multi_ret[old_task.name] = True

        # set this syscall for gcfg building
        state.last_syscall = SyscallInfo("ActivateTask", abb, cpu)

        # print("Activate Task: " + task.name)

        return state

    @syscall
    def AUTOSAR_AdvanceCounter(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_CancelAlarm(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_ChainTask(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_CheckAlarm(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_ClearEvent(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_DisableAllInterrupts(cfg, abb, state, cpu):
        new_state = state.copy()

        new_state.interrupts_enabled = False
        
        scheduled_task = state.get_scheduled_instance()

        # advance task or isr to next abb
        new_state.abbs[scheduled_task.name] = next(cfg.vertex(abb).out_neighbors())
            
        return new_state

    @syscall
    def AUTOSAR_EnableAllInterrupts(cfg, abb, state, cpu):
        new_state = state.copy()

        new_state.interrupts_enabled = True
        
        scheduled_task = state.get_scheduled_instance()

        # advance task or isr to next abb
        new_state.abbs[scheduled_task.name] = next(cfg.vertex(abb).out_neighbors())
            
        return new_state

    @syscall
    def AUTOSAR_GetAlarm(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_GetEvent(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_GetResource(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_ReleaseResource(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_ResumeAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_ResumeOSInterrupts(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_SetEvent(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_SetRelAlarm(cfg, abb, state):
        pass

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

    @syscall
    def AUTOSAR_TerminateTask(cfg, abb, state, cpu):
        state = state.copy()

        # remove task from activated tasks list
        scheduled_task = state.get_scheduled_task()
        state.activated_tasks.remove(scheduled_task)

        # reset abb list to entry abb
        state.abbs[scheduled_task.name] = state.entry_abbs[scheduled_task.name]

        # set this syscall for gcfg building
        state.last_syscall = SyscallInfo("TerminateTask", abb, cpu)

        # set multi ret in syscall info
        # new_task = state.get_scheduled_task()
        # if new_task is not None:
        #     if state.gcfg_multi_ret[new_task.name]:
        #         state.last_syscall.set_multi_ret()

        #         # reset multi ret for gcfg building to False
        #         state.gcfg_multi_ret[new_task.name] = False

        # print("Terminated Task: " + scheduled_task.name)

        return state

    @syscall
    def AUTOSAR_WaitEvent(cfg, abb, state):
        pass
