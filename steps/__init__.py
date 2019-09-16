from .oil import OilStep
from .old_syscalls import SyscallStep
from .syscall import Syscall
from .abb_merge_old import ABB_MergeStep
from .display_results import DisplayResultsStep
from .printer import Printer
from .python_validation import Python_ValidationStep
from .dummy import Dummy

import py_logging

from native_step import Step
from native_step import provide_steps as _native_provide

__all__ = ['Step',
           'ABB_MergeStep',
           'Dummy',
           'Syscall',
           'OilStep',
           'Python_ValidationStep'
           'SyscallStep']


def provide_steps():
    for step in _native_provide():
        yield step

    yield OilStep()
    yield SyscallStep()
    yield Syscall()
    yield ABB_MergeStep()
    yield DisplayResultsStep()
    yield Printer()
    yield Python_ValidationStep()
    yield Dummy()
