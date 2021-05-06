
from typing import List

_os_models = None # Dictionary with names -> OS-model-object
_syscalls = None # Caches get_os_syscalls() return value.

def init_os_package():
    """ Initializes this package.

        It is not required to call this function.
        All functions in this file will call this function automatically to ensure _os_models is initlialized.
        This function is a workaround to force Python not to load the OS models at program startup where some objects are not correctly initialized.
    """
    global _os_models
    if _os_models == None:

        # Register your new OS Model here:
        from .freertos import FreeRTOS
        from .osek import OSEK
        from .autosar import AUTOSAR
        from .posix.posix import POSIX

        # And here:
        _os_models = {
            "FreeRTOS": FreeRTOS,
            "OSEK": OSEK,
            "AUTOSAR": AUTOSAR,
            "POSIX": POSIX
        }


def get_os_model_names() -> List[str]:
    init_os_package()
    return list(_os_models.keys())

def get_os_model_by_name(name: str):
    init_os_package()
    return _os_models[name]


def get_os_syscalls(os):
    return [(x, os) for x in dir(os) if hasattr(getattr(os, x), 'syscall')]

def get_syscalls():
    init_os_package()
    global _syscalls
    if _syscalls == None:
        _syscalls = sum(map(get_os_syscalls, list(_os_models.values())), [])
    return _syscalls


def get_os_syscall_list(os_model) -> List[str]:
    """ Returns a list of all syscall names from os_model. """
    return map( (lambda x_os : x_os[0]), 
                   get_os_syscalls(os_model))

def get_posix_syscalls() -> List[str]:
    """ Returns a list of all POSIX syscall names.

        This function will be called by the remove_syscall_body native step.
        The sole purpose of this function is to ease the native call.
    """
    init_os_package()
    return get_os_syscall_list(get_os_model_by_name("POSIX"))