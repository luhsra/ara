from .abb_merge import ABBMerge
from .dummy import Dummy
from .oil import OilStep
from .printer import Printer
from .sse import SSE
from .syscall import Syscall
from .value_analysis import ValueAnalysis

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
    yield SSE()
    yield Syscall()
    yield ValueAnalysis()
