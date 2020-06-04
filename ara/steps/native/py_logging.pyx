# cython: language_level=3
from libcpp.string cimport string
from cpython.ref cimport PyObject
from cython.operator cimport dereference as deref

import logging

cdef public enum LogLevel:
    CRITICAL = 50
    ERROR = 40
    WARNING = 30
    INFO = 20
    DEBUG = 10
    NOTSET = 0


cdef public struct PyLogger:
    LogLevel level
    PyObject* logger


cdef public LogLevel py_log_get_level(object py_logger):
    cdef int lvl = py_logger.getEffectiveLevel()
    return <LogLevel> lvl;


cdef public void py_log(LogLevel level, PyLogger& logger, string msg):
    cdef LogLevel lvl = logger.level
    # short path
    if level < lvl:
        return

    log = <object> logger.logger
    if level == CRITICAL:
        log.critical(msg.decode('UTF-8'))
        return
    if level == ERROR:
        log.error(msg.decode('UTF-8'))
        return
    if level == WARNING:
        log.warn(msg.decode('UTF-8'))
        return
    if level == INFO:
        log.info(msg.decode('UTF-8'))
        return
    if level == DEBUG:
        log.debug(msg.decode('UTF-8'))
        return
