# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from ..os_generic import GenericOS
from ..elements.IncludeManager import Include

from .arch_arm import ArmArch

from .syscall_generic import GenericSystemCalls
from .implementations import add_impl as _add_impl



class FreeRTOSGenericOS(GenericOS):

    arch_choices = {'arm':ArmArch}


    def set_generator(self, generator):
        super().set_generator(generator)
        self.generator.add_source_file('.freertos_overrides.h')

    @staticmethod
    def get_dependencies():
        return ['ClassifySpecializationsFreeRTOS']

    def get_syscall_rules(self):
        return GenericSystemCalls

    def get_arch_rules(self, arch):
        return self.arch_choices[arch]

    def generate_data_objects(self):
        #include "freertos.h"
        self.generator.source_file.includes.add(Include('FreeRTOS.h'))

    def generate_system_code(self):
        self.calculate_heap_declinement()


    def calculate_heap_declinement(self):
        heap_size_total = self.ara_graph.os.total_heap_size()
        if heap_size_total is None:
            self._log.warning("heap calculation not possible: heap_size is None")
        heap_usage_sure = 0
        heap_usage_maybe = 0
        heap_decline = 0
        for v in self.ara_graph.instances.vertices():
            inst = self.ara_graph.instances.vp.obj[v]
            self._log.debug("%s(%s) declines %s", inst.name, type(inst), inst.heap_decline())
            try:
                heap_decline += inst.heap_decline()
                heap_usage_maybe += inst.heap_usage_maybe()
                heap_usage_sure += inst.heap_usage_sure()
            except:
                self._log.error(inst.as_dot())

        sum_maybe = sum([heap_usage_sure, heap_usage_maybe, heap_decline])
        sum_sure = sum([heap_usage_sure, heap_decline])
        if heap_size_total < sum_maybe:
            self._log.warning("FreeRTOS heap usage might  exceed heap size: %s / %s)",
                              sum_maybe, heap_size_total)
        if heap_size_total < sum_sure:
            self._log.error("FreeRTOS heap usage exceeds heap size: %s / %s)",
                            sum_sure, heap_size_total)
        overrides = self.generator.source_files['.freertos_overrides.h'].overrides
        overrides['ara_heap_decline'] = heap_decline
        overrides['configTOTAL_HEAP_SIZE'] = heap_size_total - heap_decline

    @staticmethod
    def add_impl(instance):
        _add_impl(instance)
