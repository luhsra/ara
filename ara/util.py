# vim: set et ts=4 sw=4:
"""Utility functions."""

import sys
import logging

from itertools import tee
from graph_tool.topology import shortest_path


LEVEL = {"critical": logging.CRITICAL,
         "error": logging.ERROR,
         "warning": logging.WARNING,
         "warn": logging.WARNING,
         "info": logging.INFO,
         "debug": logging.DEBUG}


class DieOnErrorLogger(logging.getLoggerClass()):
    werr = False
    def critical(self, *args, **kwargs):
        super().error(*args, **kwargs)
        sys.exit(1)
    def error(self, *args, **kwargs):
        if self.werr:
            super().error(*args, **kwargs)
        else:
            super().error(*args, **kwargs)
    def warning(self, *args, **kwargs):
        if self.werr:
            super().error(*args, **kwargs)
            sys.exit(1)
        else:
            super().warning(*args, **kwargs)

logging.setLoggerClass(DieOnErrorLogger)

class LoggerManager:
    """Manages loggers for ARA."""
    def __init__(self):
        self._log_level = logging.WARNING
        self._logger_levels = {}
        self._loggers = {}

    def set_log_level(self, level):
        """Set global log level. All loggers will be adjusted."""
        self._log_level = level
        for logger in self._loggers.values():
            logger.setLevel(level)

    def set_logger_levels(self, levels):
        """Set levels for loggers. Updates all existing loggers."""
        self._logger_levels = levels
        for name in levels:
            if name in self._loggers:
                self._loggers[name].setLevel(levels[name])

    def get_log_level(self, logger=None):
        """Get the global or logger specific loglevel."""
        if logger and logger in self._logger_levels:
            return self._logger_levels[logger]
        return self._log_level

    def get_logger(self, name: str, level=None):
        """Get a sublogger with an preinitialized level.

        Arguments:
        name  -- name of the sublogger
        level -- Level of the sublogger (default: the global log level)
        """
        if not level:
            level = self.get_log_level(name)
        logger = logging.getLogger(name)
        logger.setLevel(level)
        self._loggers[name] = logger
        return logger

    @staticmethod
    def _matplotlib_logging_hack():
        """We are using a global logger on level default. However, this leads to a
        bunch of (unwanted) log output from matplotlib. We are not using matplotlib
        in any way, but it is loaded as a dependency of graph tool. This function
        sets matplotlib internal logging to the ARA global level.
        """
        try:
            import matplotlib
            matplotlib.set_loglevel("critical")
        except:
            # absolutely not relevant
            pass




# place this in a global variable to make a singleton out of it
# this is to circumvent one restriction of the Python logging framework that
# allows only log levels below the root log levels for subloggers. We don't want
# this for ARA.
# Access this variable with get_logger_manager()
_logger_manager = LoggerManager()


def get_logger_manager():
    global _logger_manager
    return _logger_manager


def get_logger(name: str, level=None):
    """Convenience method. See LoggerManager.get_logger."""
    return get_logger_manager().get_logger(name, level)


def get_null_logger():
    """Get a logger that does absolutely nothing."""
    null = logging.getLogger('null')
    null.disabled = True
    return null


def init_logging(level=logging.DEBUG, max_stepname=20, root_name='root', werr=False):
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
        level = LEVEL[level]

    logger_manager = get_logger_manager()
    logger_manager.set_log_level(level)
    logger_manager._matplotlib_logging_hack()
    logging.basicConfig(format=_format, level=logging.DEBUG)
    DieOnErrorLogger.werr = werr
    return logger_manager.get_logger(root_name, level)


def dominates(dom_tree, x, y):
    """Does node x dominate node y?"""
    while y:
        if x == y:
            return True
        y = dom_tree[y]
    return False


def has_path( graph, source, target):
    """Is there a path from source to target?"""
    _, elist = shortest_path(graph, source, target)
    return len(elist) > 0


def pairwise(iterable):
    """Backport of Python pairwise. See itertools.pairwise."""
    # pairwise('ABCDEFG') --> AB BC CD DE EF FG
    version = sys.version_info
    if version.major >= 3 and version.minor >= 10:
        log = get_logger("util")
        log.warn("You are using Python 3.10. Consider switching to native "
                 "pairwise.")
        from itertools import pairwise as pw
        return pw(iterable)

    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)


class VarianceDict(dict):
    """Dict that store the values that are requested per `get`."""
    def get(self, key, default_value):
        if key in self:
            return self[key]
        self[key] = default_value
        return self[key]
