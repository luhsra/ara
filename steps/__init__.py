from .abb_merge import ABBMerge
from .dummy import Dummy
from .oil import OilStep
from .printer import Printer
from .syscall import Syscall

import py_logging

from native_step import Step
from native_step import provide_steps as _native_provide


def provide_steps():
    for step in _native_provide():
        yield step

    yield ABBMerge()
    yield Dummy()
    yield OilStep()
    yield Printer()
    yield Syscall()
