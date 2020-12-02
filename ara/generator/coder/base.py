

class BaseCoder:

    def __init__(self):
        self.generator = None
        self.ara_graph = None

        self.arch_rules = None
        self.os_rules = None
        self.instantiation_rules = None
        self.interaction_rules = None
        self._log = None


    def set_generator(self, generator):
        self.generator = generator
        self.ara_graph = generator.ara_graph
        self.instantiation_rules = generator.instantiation_rules
        self.interaction_rules = generator.interaction_rules
        self.arch_rules = generator.arch_rules
        self.os_rules = generator.os_rules
        self._log = generator._log.getChild(self.__class__.__name__)


    def generate_data_objects(self):
        self._log.info("generate_data_objects not implemented: %s",
                            self)

    def generate_system_code(self):
        self._log.info("generate_system_code not implemented: %s",
                            self)
