import os
from .coder.elements import SourceFile, Include
from .coder.implementations import add_impl

class Generator:
    def __init__(self, ara_graph, ara_step, arch_rules, os_rules, syscall_rules, _log):
        self.ara_graph = ara_graph
        self.ara_step = ara_step
        self.ara_graph.generator = self
        self.arch_rules = arch_rules
        self.os_rules = os_rules
        self.syscall_rules = syscall_rules
        self._log = _log
        self._dependencies = []

        self.file_prefix = None
        self.source_file = None
        self.source_files = dict()
        self.template_base = os.path.dirname(os.path.abspath(__file__))

        os_rules.set_generator(self)
        arch_rules.set_generator(self)
        syscall_rules.set_generator(self)


    def generate(self, out_file, passthrough=False):
        self.file_prefix = out_file

        self.source_file = SourceFile(self._log)
        self.source_files[''] = self.source_file

        #include "freertos.h"
        self.source_file.includes.add(Include('FreeRTOS.h'))

        if not passthrough:
            self.generate_code()
        self.generate_startup_code()
        self.generate_linkerscript()
        self.write_out()

    def generate_code(self):
        # storage for generated source elements
        for v in self.ara_graph.instances.vertices():
            instance = self.ara_graph.instances.vp.obj[v]
            add_impl(instance)

        # generate all system objects
        self.arch_rules.generate_data_objects()
        self.os_rules.generate_data_objects()
        self.syscall_rules.generate_data_objects()

        #generate os and system code
        self.arch_rules.generate_system_code()
        self.os_rules.generate_system_code()
        self.syscall_rules.generate_system_code()


        self.arch_rules.generate_default_interrupt_handlers()

    def generate_startup_code(self):
        self.arch_rules.generate_startup_code()

    def generate_linkerscript(self):
        self.arch_rules.generate_linkerscript()

    def write_out(self):
        #write results outgoing
        for name, content in self.source_files.items():
            with self.open_file(name) as f:
                data = content.expand(self)
                f.write(data)


    def open_file(self, name, mode='w+'):
        # if not os.path.isdir(self.file_prefix):
        #     os.mkdir(self.file_prefix)
        return open(self.file_prefix + name, mode)

    def open_template(self, name):
        return open(os.path.join(self.template_base, name))

    def add_source_file(self, name):
        self.source_files[name] = SourceFile(self._log)

    def get_dependencies(self):
        return self._dependencies

    def add_dependency(self, dependency):
        self._dependencies.append(dependency)
