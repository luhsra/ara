import os
from .coder.elements import SourceFile, Include
from .coder.implementations import TaskImpl

class Generator:
    def __init__(self, ara_graph, arch_rules, os_rules, syscall_rules, logger):
        self.ara_graph = ara_graph
        self.ara_graph.generator = self
        self.arch_rules = arch_rules
        self.os_rules = os_rules
        self.syscall_rules = syscall_rules
        self.logger = logger

        self.file_prefix = None
        self.source_file = None
        self.source_files = dict()

        os_rules.set_generator(self)
        arch_rules.set_generator(self)
        syscall_rules.set_generator(self)


    def generate(self, out_file):
        self.file_prefix = out_file

        self.source_file = SourceFile()
        self.source_files[''] = self.source_file

        #include "freertos.h"
        self.source_file.includes.add(Include('FreeRTOS.h'))

        # storage for generated source elements
        for v in self.ara_graph.instances.vertices():
            task = self.ara_graph.instances.vp.obj[v]
            task.impl = TaskImpl()

        # generate all system objects
        self.arch_rules.generate_data_objects()
        self.os_rules.generate_data_objects()
        self.syscall_rules.generate_data_objects()

        #generate os and system code
        self.arch_rules.generate_system_code()
        self.os_rules.generate_system_code()
        self.syscall_rules.generate_system_code()


        self.arch_rules.generate_default_interrupt_handlers()

        self.arch_rules.generate_linkerscript()

        #write results outgoing
        for name, content in self.source_files.items():
            with self.open_file(name) as f:
                data = content.expand(self)
                f.write(data)


    def open_file(self, name, mode='w+'):
        # if not os.path.isdir(self.file_prefix):
        #     os.mkdir(self.file_prefix)
        return open(self.file_prefix + name, mode)
