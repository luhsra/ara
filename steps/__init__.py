from .oil import OilStep
from .syscalls import SyscallStep
from .abb_merge import ABB_MergeStep
from .display_results import DisplayResultsStep
from .python_validation import Python_ValidationStep
from .dummy import Dummy

import py_logging

from native_step import Step
from native_step import provide_steps as _native_provide

__all__ = ['Step',
           'ABB_MergeStep',
           'Dummy',
           'OilStep',
           'Python_ValidationStep'
           'SyscallStep']


def provide_steps(config: dict):
    for step in _native_provide(config):
        yield step

    yield OilStep(config)
    yield SyscallStep(config)
    yield ABB_MergeStep(config)
    yield DisplayResultsStep(config)
    yield Python_ValidationStep(config)
    yield Dummy(config)
