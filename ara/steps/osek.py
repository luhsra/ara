from .os_util import syscall
from .os_base import OSBase

class OSEK(OSBase):

    @staticmethod
    def init(state):
        pass

    @syscall
    def OSEKOS_ActivateTask(cfg, state):
        pass

    @syscall
    def OSEKOS_ActivateTask(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_AdvanceCounter(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_CancelAlarm(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_ChainTask(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_CheckAlarm(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_ClearEvent(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_DisableAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_EnableAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_GetAlarm(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_GetEvent(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_GetResource(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_ReleaseResource(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_ResumeAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_ResumeOSInterrupts(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_SetEvent(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_SetRelAlarm(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_ShutdownOS(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_StartOS(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_SuspendAllInterrupts(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_SuspendOSInterrupts(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_TerminateTask(cfg, abb, state):
        pass

    @syscall
    def OSEKOS_WaitEvent(cfg, abb, state):
        pass
