from .oil import OilStep
from .syscalls import SyscallStep

from native_step import Step
from native_step import provide_steps as _native_provide

__all__ = ['Step', 'OilStep', 'SyscallStep']

def provide_steps(config: dict):
    for step in  _native_provide(config):
        yield step

    yield OilStep(config)
    yield SyscallStep(config)
