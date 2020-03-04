from .os_util import syscall

class OSEK:

    @syscall
    def OSEKOS_ActivateTask(cfg, state):
        pass

# OS_API = [
#     # OSEK
#     {
#         "name": "OSEKOS_ActivateTask",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_StartOS",
#         "os": OS.OSEK,
#         "type": SyscallType.START,
#     },
#     {
#         "name": "OSEKOS_ShutdownOS",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_TerminateTask",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_ChainTask",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_CancelAlarm",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_GetResource",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_ReleaseResource",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_DisableAllInterrupts",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_EnableAllInterrupts",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_SuspendAllInterrupts",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_ResumeAllInterrupts",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_SuspendOSInterrupts",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_ResumeOSInterrupts",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_GetAlarm",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_AdvanceCounter",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_SetEvent",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_ClearEvent",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_WaitEvent",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_GetEvent",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_SetRelAlarm",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
#     {
#         "name": "OSEKOS_CheckAlarm",
#         "os": OS.OSEK,
#         "type": SyscallType.DEFAULT,
#     },
