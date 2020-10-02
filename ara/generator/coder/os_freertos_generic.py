from .os_generic import GenericOS

class FreeRTOSGenericOS(GenericOS):

    def set_generator(self, generator):
        super().set_generator(generator)
        self.generator.add_source_file('.freertos_overrides.h')
    def generate_data_objects(self):
        self._log.info("FreeRTOSGenericOS has no data objects")
        pass
