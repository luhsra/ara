from .os_util import syscall
from .os_base import OSBase
from ara.util import get_logger

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
    def interpret(cfg, abb, state):
        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}")
        return getattr(AUTOSAR, syscall)(cfg, abb, state)

    @syscall
    def AUTOSAR_ActivateTask(cfg, abb, state):
        pass

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
    def AUTOSAR_TerminateTask(cfg, abb, state):
        pass

    @syscall
    def AUTOSAR_WaitEvent(cfg, abb, state):
        pass
