from ..os_generic import GenericOS
from ..elements.IncludeManager import Include

from .arch_generic import GenericArch

from .syscall_generic import GenericSystemCalls

class ZephyrGenericOS(GenericOS):

    arch_choices = {'generic': GenericArch}

    def set_generator(self, generator):
        super().set_generator(generator)

    @staticmethod
    def get_dependencies():
        return []

    def get_syscall_rules(self):
        return GenericSystemCalls

    def get_arch_rules(self, arch):
        return self.arch_choices[arch]

    # def generate_data_objects(self):
    #     pass
    # 
    # def generate_system_code(self):
    #     pass

