"""Helper functions that are needed in multiple places."""


def raise_and_error(logger, message, exception=RuntimeError):
    """Error log message and raise it as exception."""
    logger.error(message)
    raise exception(message)
