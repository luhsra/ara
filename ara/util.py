# vim: set et ts=4 sw=4:
"""Utility functions."""

import sys
import logging
import re
import functools

from inspect import Parameter, signature
from itertools import tee, chain, repeat
from graph_tool.topology import shortest_path


LEVEL = {"critical": logging.CRITICAL,
         "error": logging.ERROR,
         "warning": logging.WARNING,
         "warn": logging.WARNING,
         "info": logging.INFO,
         "debug": logging.DEBUG}


class ContinueSignal(Exception):
    """Something in an inner loop happened that should cause the outer loop to
    continue.

    Use as:
    ```
    for i in range(10):
        try:
            for j in range(5):
                if condition:
                    raise ContinueSignal
        except ContinueSignal:
            continue
    ```
    """
    pass


class BreakSignal(Exception):
    """Something in an inner loop happened that should cause the outer loop to
    break.

    Use as:
    ```
    for i in range(10):
        try:
            for j in range(5):
                if condition:
                    raise BreakSignal
        except BreakSignal:
            break
    ```
    """
    pass


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

    def get_logger(self, name: str, level=None, inherit=False):
        """Get a sublogger with an preinitialized level.

        Arguments:
        name    -- name of the sublogger
        level   -- Level of the sublogger (default: the global log level)
        inherit -- If the logger is a child logger ("A.B", B derives from
                   child), then inherit the level from the parent. Note,
                   that this works in one direction only due to the nature
                   of Python logging. So only if the parent has a more
                   detailed level as ARA itself, it will be transferred
                   the to child.
        """
        if not level:
            if inherit:
                level = logging.NOTSET
            else:
                level = self.get_log_level(name)
        logger = logging.getLogger(name)
        logger.setLevel(level)
        self._loggers[name] = logger
        return logger

    @staticmethod
    def _matplotlib_logging_hack():
        """We are using a global logger on level default. However, this leads
        to a bunch of (unwanted) log output from matplotlib. We are not using
        matplotlib in any way, but it is loaded as a dependency of graph tool.
        This function sets matplotlib internal logging to the ARA global level.
        """
        try:
            import matplotlib
            matplotlib.set_loglevel("critical")
        except:
            # absolutely not relevant
            pass


# place this in a global variable to make a singleton out of it
# this is to circumvent one restriction of the Python logging framework that
# allows only log levels below the root log levels for subloggers. We don't
# want # this for ARA.
# Access this variable with get_logger_manager()
_logger_manager = LoggerManager()


def get_logger_manager():
    global _logger_manager
    return _logger_manager


def get_logger(name: str, level=None, inherit=False):
    """Convenience method. See LoggerManager.get_logger."""
    return get_logger_manager().get_logger(name, level, inherit)


def get_null_logger():
    """Get a logger that does absolutely nothing."""
    null = logging.getLogger('null')
    null.disabled = True
    return null


def init_logging(level=logging.DEBUG, max_stepname=20, root_name='root',
                 werr=False):
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


def has_path(graph, source, target):
    """Is there a path from source to target?"""
    _, elist = shortest_path(graph, source, target)
    return len(elist) > 0


def pairwise(iterable):
    """Backport of Python pairwise. See itertools.pairwise."""
    # pairwise('ABCDEFG') --> AB BC CD DE EF FG
    version = sys.version_info
    if version.major >= 3 and version.minor >= 10:
        log = get_logger("util")
        log.warning("You are using Python 3.10 and ara.util.pairwise. "
                    "Consider switching to native pairwise from itertools.")
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


class KConfigFile(dict):
    """A collection of KConfig settings. Stores them as key, value pairs."""
    def __init__(self, conf: str):
        dict.__init__(self)

        with open(conf, 'r') as f:
            # Regex used to delete all whitespace, comments and quotes from the key=value entry.
            strip = re.compile(r'\s+|"|#.*')
            for line in f.readlines():
                line = re.sub(strip, '', line)
                tokens = line.split('=')

                if len(tokens) != 2:
                    continue

                self[tokens[0]] = tokens[1]


llvm_suffix = re.compile(".+\.\d+")
def drop_llvm_suffix(name: str) -> str:
    """Remove the llvm suffix from a name

    E.g. sleep.5 -> sleep
    """
    if llvm_suffix.match(name) is not None:
        return name.rsplit('.', 1)[0]
    return name


def debug_log(original_function=None, *,
              hide_inner_output: bool = False,
              logger: logging.Logger = None):
    """Decorator for an automatic function log.

    It logs all input and output to the given logger, or, if logger is not
    given, to self._log. If hide_inner_output is specified it also sets the
    loglevel for all innner output to CRITICAL thus effectively preventing
    every internal output.
    """

    def _decorate(function):

        @functools.wraps(function)
        def wrapped_function(*args, **kwargs):
            if logger is None:
                log = args[0]._log
            else:
                log = logger

            sig = signature(function)
            res = f"Call to {function.__name__}("
            parms = []
            for parm, value in zip(sig.parameters.values(),
                                   chain(args, repeat(None))):
                if parm.default != Parameter.empty:
                    # keyword argument
                    kvalue = kwargs.get(parm.name, parm.default)
                    parms.append(f"{parm.name}={kvalue}")
                else:
                    parms.append(f"{parm.name}={value}")

            res += ", ".join(parms) + ")"
            log.debug(res)
            if hide_inner_output:
                logging.disable()
            ret = function(*args, **kwargs)
            if hide_inner_output:
                # enable again
                logging.disable(logging.NOTSET)
            log.debug(f"The result is: {ret}")
            return ret

        return wrapped_function

    if original_function:
        return _decorate(original_function)

    return _decorate
