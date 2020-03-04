

class BaseCoder:

    def __init__(self):
        self.generator = None
        self.ara_graph = None

        self.arch_rules = None
        self.os_rules = None
        self.syscall_rules = None
        self.logger = None


    def set_generator(self, generator):
        self.generator = generator
        self.ara_graph = generator.ara_graph
        self.syscall_rules = generator.syscall_rules
        self.arch_rules = generator.arch_rules
        self.os_rules = generator.os_rules
        self.logger = generator.logger


    def generate_data_objects(self):
        self.logger.warning("generate_data_objects not implemented: %s",
                            self)

    def generate_system_code(self):
        self.logger.warning("generate_system_code not implemented: %s",
                            self)
