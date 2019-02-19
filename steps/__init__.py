from .oil import OilStep
from .syscalls import SyscallStep
from .abb_merge import ABB_MergeStep
from .display_results import DisplayResultsStep
from .python_validation import Python_ValidationStep

import py_logging

from native_step import Step
from native_step import provide_steps as _native_provide

__all__ = ['Step', 'OilStep', 'SyscallStep', 'ABB_MergeStep', 'Python_ValidationStep']

def provide_steps(config: dict):
    for step in  _native_provide(config):
        yield step

    yield OilStep(config)
    yield SyscallStep(config)
    yield ABB_MergeStep(config)
    yield DisplayResultsStep(config)
    yield Python_ValidationStep(config)
