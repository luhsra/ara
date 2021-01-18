def get_oses():
    """Return all supported OSes."""
    from .freertos import FreeRTOS
    from .osek import OSEK
    from .autosar import AUTOSAR
    from .zephyr import ZEPHYR
    return [FreeRTOS, OSEK, AUTOSAR, ZEPHYR]
