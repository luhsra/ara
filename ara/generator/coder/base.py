# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later
from .elements import (FunctionCall, VariableDefinition)


class BaseCoder:

    def call(self,
             block,
             function,
             rettype="void",
             arguments=None,
             prepend=False,
             name=None):
        """Generates a call to a function and stores the result in an
           variable, if it isn't void"""

        if not name:
            ret_var = VariableDefinition.new(self.generator, rettype)
            if ret_var:
                block.add(ret_var)
                name = ret_var.name

        if arguments is None:
            arguments = []
        if prepend:
            block.prepend(FunctionCall(function, arguments, name))
        else:
            block.add(FunctionCall(function, arguments, name))

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
        self.arch_rules = generator.arch_rules
        self.os_rules = generator.os_rules
        self.syscall_rules = generator.syscall_rules
        self._log = generator._log.getChild(self.__class__.__name__)

    def generate_data_objects(self):
        self._log.info("generate_data_objects not implemented: %s", self)

    def generate_system_code(self):
        self._log.info("generate_system_code not implemented: %s", self)
