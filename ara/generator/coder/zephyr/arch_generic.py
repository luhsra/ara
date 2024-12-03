from ..base import BaseCoder
from ..elements import StructDataObject, DataObjectArray, DataObject
from ara.os.zephyr import Queue, Mutex

class GenericArch(BaseCoder):

    def __init__(self):
        BaseCoder.__init__(self)

    def generate_linkerscript(self):
        self._log.error("generate_linkerscript not implemented: %s", self)

    def generate_default_interrupt_handlers(self):
        self._log.error(
            "generate_default_interrupt_handlers not implemented: %s", self)

    def generate_startup_code(self):
        self._log.error("generate_startup_code not implemented: %s", self)

    def generate_data_objects(self):
        pass

    def generate_system_code(self):
        pass
