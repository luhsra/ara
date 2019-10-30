from .oil import OilStep
from .syscall import Syscall
from .abb_merge import ABBMerge
from .printer import Printer
from .dummy import Dummy

import py_logging

from native_step import Step
from native_step import provide_steps as _native_provide

__all__ = ['Step',
           'ABBMerge',
           'Dummy',
           'Syscall']


def provide_steps():
    for step in _native_provide():
        yield step

    yield ABBMerge()
    yield Dummy()
    yield OilStep()
    yield Printer()
    yield Syscall()
