from .base import BaseCoder

class GenericArch(BaseCoder):

    def generate_linkerscript(self):
        self.logger.warning("generate_linkerscript not implemented: %s",
                            self)

    def generate_default_interrupt_handlers(self):
        self.logger.warning("generate_default_interrupt_handlers not implemented: %s",
                            self)
        


    pass
