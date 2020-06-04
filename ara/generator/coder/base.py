

class BaseCoder:

    def __init__(self):
        self.generator = None
        self.ara_graph = None

        self.arch_rules = None
        self.os_rules = None
        self.syscall_rules = None
        self._log = None


    def set_generator(self, generator):
        self.generator = generator
        self.ara_graph = generator.ara_graph
        self.syscall_rules = generator.syscall_rules
        self.arch_rules = generator.arch_rules
        self.os_rules = generator.os_rules
        self._log = generator._log.getChild(self.__class__.__name__)


    def generate_data_objects(self):
        self._log.warning("generate_data_objects not implemented: %s",
                            self)

    def generate_system_code(self):
        self._log.warning("generate_system_code not implemented: %s",
                            self)
