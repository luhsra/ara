# vim: set et ts=4 sw=4:
"""Utility functions."""

import logging

# place this in a global variable to make a singleton out of it
# this is to circumvent one restriction of the Python logging framework that
# allows only log levels below the root log levels for subloggers. We don't want
# this for ARA.
# Access this variable with get_log_level()
_global_log_level = logging.DEBUG


def get_log_level():
    """Get the global loglevel."""
    global _global_log_level
    return _global_log_level


def get_logger(name: str, level=None):
    """Get a sublogger with an preinitialized level.

    Arguments:
    name  -- name of the sublogger
    level -- Level of the sublogger (default: the global log level)
    """
    if not level:
        level = get_log_level()
    logger = logging.getLogger(name)
    logger.setLevel(level)
    return logger


def init_logging(level=logging.DEBUG, max_stepname=20, root_name='root'):
    """Init logging with color and timestamps.

    Returns a root logger with correct log level.

    Keyword arguments:
    level        -- root log level
    max_stepname -- length of longest name for the sublogger
    root_name    -- name of the returned root logger
    """
    if logging.root.handlers:
        raise RuntimeWarning("Logging already setup")
    logging.addLevelName(logging.WARNING, "\033[1;33m%s\033[1;0m" % logging.getLevelName(logging.WARNING))
    logging.addLevelName(logging.ERROR, "\033[1;41m%s\033[1;0m" % logging.getLevelName(logging.ERROR))
    logging.addLevelName(logging.DEBUG, "\033[1;32m%s\033[1;0m" % logging.getLevelName(logging.DEBUG))
    logging.addLevelName(logging.INFO, "\033[1;34m%s\033[1;0m" % logging.getLevelName(logging.INFO))
    max_l = max([len(logging.getLevelName(l)) for l in range(logging.CRITICAL)])
    _format = f'%(asctime)s %(levelname)-{max_l}s %(name)-{max_stepname+1}s %(message)s'
    if type(level) == str:
        log_levels = {'debug': logging.DEBUG,
                      'info': logging.INFO,
                      'warning': logging.WARNING,
                      'warn': logging.WARNING}
        level = log_levels[level]

    global _global_log_level
    _global_log_level = level
    logging.basicConfig(format=_format, level=logging.DEBUG)
    return get_logger(root_name, level)


class VarianceDict(dict):
    """Dict that store the values that are requested per `get`."""
    def get(self, key, default_value):
        if key in self:
            return self[key]
        self[key] = default_value
        return self[key]
