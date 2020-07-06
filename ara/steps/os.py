from .freertos import FreeRTOS
from .osek import OSEK
from .autosar import AUTOSAR

def get_os_syscalls(os):
    return [(x, os) for x in dir(os) if hasattr(getattr(os, x), 'syscall')]

def get_syscalls():
    return sum(map(get_os_syscalls, [FreeRTOS, OSEK, AUTOSAR]), [])
