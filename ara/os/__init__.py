def get_os_syscalls(os):
    return [(x, os) for x in dir(os) if hasattr(getattr(os, x), 'syscall')]

_os_syscalls = None # Cache get_os_syscalls() return value. 

def get_syscalls():
    from .freertos import FreeRTOS
    from .osek import OSEK
    from .autosar import AUTOSAR
    from .posix.posix import POSIX
    global _os_syscalls
    if _os_syscalls == None:
        _os_syscalls = sum(map(get_os_syscalls, [FreeRTOS, OSEK, AUTOSAR, POSIX]), [])
    return _os_syscalls

def get_posix_syscalls():
    """ Returns a list of all POSIX syscall names.

        This function will be called by the remove_syscall_def native step.
    """
    from .posix.posix import POSIX
    return map( (lambda x_os : x_os[0]), 
                   filter( (lambda x_os : x_os[1] == POSIX), get_syscalls()))
