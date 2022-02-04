
from typing import List

_os_models : dict = None # Dictionary with names -> OS-model-object

def init_os_package():
    """Initializes this package.

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
        from .zephyr import ZEPHYR
        from .posix.posix import POSIX
        # TODO: Add POSIX here

        _os_models = {model.__name__: model for model 
                            in [FreeRTOS, OSEK, AUTOSAR, ZEPHYR, POSIX]} # And here


def get_os_model_names() -> List[str]:
    """Return all supported OSes as string."""
    init_os_package()
    return list(_os_models.keys())

def get_os_model_by_name(name: str):
    """Return the os called name."""
    init_os_package()
    return _os_models[name]

def get_oses() -> List:
    """Return all supported OSes as os model objects."""
    init_os_package()
    return _os_models.values()
