from .os_generic import GenericOS
from .elements.IncludeManager import Include

class FreeRTOSGenericOS(GenericOS):

    def set_generator(self, generator):
        super().set_generator(generator)
        self.generator.add_source_file('.freertos_overrides.h')
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
