from .os_util import syscall
from .os_base import OSBase
from ara.util import get_logger
from ara.graph.argument import CallPath

logger = get_logger("AUTOSAR")

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
    def interpret(cfg, abb, state, cpu):
        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}")
        return getattr(AUTOSAR, syscall)(cfg, abb, state, cpu)

    @staticmethod
    def schedule(state, cpu):
        # sort actived tasks by priority
        state.activated_tasks[cpu].sort(key=lambda task: task.priority, reverse=True)


    @syscall
    def AUTOSAR_ActivateTask(cfg, abb, state, cpu):
        state = state.copy()
        scheduled_task = state.get_scheduled_task(cpu)

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
        if task not in state.activated_tasks[task.cpu_id]:
            state.activated_tasks[task.cpu_id].append(task)

        # advance current task to next abb
        counter = 0
        state.abbs[scheduled_task.name] = []
        for n in cfg.vertex(abb).out_neighbors():
            state.abbs[scheduled_task.name].append(n)
            counter += 1
        assert(counter == 1)

        # trigger scheduling 
        AUTOSAR.schedule(state, task.cpu_id)

        print("Activate Task: " + task.name)

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
    def AUTOSAR_DisableAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_EnableAllInterrupts(cfg, abb, state):
        pass

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
        scheduled_task = state.get_scheduled_task(cpu)
        state.activated_tasks[cpu].remove(scheduled_task)

        # reset abb list to entry abb
        state.abbs[scheduled_task.name] = [state.entry_abbs[scheduled_task.name]]

        print("Terminated Task: " + scheduled_task.name)

        return state

    @syscall
    def AUTOSAR_WaitEvent(cfg, abb, state):
        pass
