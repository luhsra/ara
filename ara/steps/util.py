"""Helper functions that are needed in multiple places."""


def raise_and_error(logger, message, exception=RuntimeError):
    """Error log message and raise it as exception."""
    logger.error(message)
    raise exception(message)

class Wrapper:
    def set_wrappee(self, wrappee):
        self.__wrappee = wrappee

    def __getattr__(self, attr):
        return getattr(self.__wrappee, attr)
current_step = Wrapper()
