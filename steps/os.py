from .freertos import FreeRTOS
from .osek import OSEK

def get_os_syscalls(os):
    return [(x, os) for x in dir(os) if hasattr(getattr(os, x), 'syscall')]

def get_syscalls():
    return get_os_syscalls(FreeRTOS) + get_os_syscalls(OSEK)
