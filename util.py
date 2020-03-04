# vim: set et ts=4 sw=4:
"""Utility functions."""

import logging


def init_logging(level=logging.DEBUG, max_stepname=20):
    """Init logging with color and timestamps."""
    if logging.root.handlers:
        raise RuntimeWarning("Logging already setup")
    logging.addLevelName(logging.WARNING, "\033[1;33m%s\033[1;0m" % logging.getLevelName(logging.WARNING))
    logging.addLevelName(logging.ERROR, "\033[1;41m%s\033[1;0m" % logging.getLevelName(logging.ERROR))
    logging.addLevelName(logging.DEBUG, "\033[1;32m%s\033[1;0m" % logging.getLevelName(logging.DEBUG))
    logging.addLevelName(logging.INFO, "\033[1;34m%s\033[1;0m" % logging.getLevelName(logging.INFO))
    max_l = max([len(logging.getLevelName(l)) for l in range(logging.CRITICAL)])
    _format = f'%(asctime)s %(levelname)-{max_l}s %(name)-{max_stepname+1}s%(message)s'
    if type(level) == str:
        log_levels = {'debug': logging.DEBUG,
                      'info': logging.INFO,
                      'warn': logging.WARNING}
        level = log_levels[level]

    logging.basicConfig(format=_format, level=level)


class VarianceDict(dict):
    """Dict that store the values that are requested per `get`."""
    def get(self, key, default_value):
        if key in self:
            return self[key]
        self[key] = default_value
        return self[key]
