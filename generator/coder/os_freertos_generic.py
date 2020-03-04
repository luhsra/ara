from .os_generic import GenericOS

class FreeRTOSGenericOS(GenericOS):

    def generate_data_objects(self):
        self.logger.info("FreeRTOSGenericOS has no data objects")
        pass
