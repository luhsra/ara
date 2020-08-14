from .os_util import syscall
from .os_base import OSBase
from ara.util import get_logger
from ara.graph.argument import CallPath

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
    def interpret(cfg, abb, state, cpu, is_global=False):
        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}")
        if is_global:
            syscall += "_global"
        return getattr(AUTOSAR, syscall)(cfg, abb, state, cpu)

    @staticmethod
    def is_inter_cpu_syscall(cfg, abb, state, cpu):
        """Checks wether the syscall has interferences with other cpus."""
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
