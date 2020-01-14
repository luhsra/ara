from .freertos import FreeRTOS
from .osek import OSEK

def get_os_syscalls(os):
    return [(x, os) for x in os.__dict__ if hasattr(os.__dict__[x], 'syscall')]

def get_syscalls():
    return get_os_syscalls(FreeRTOS) + get_os_syscalls(OSEK)
