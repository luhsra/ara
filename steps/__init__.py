from .oil import OilStep
from .syscalls import SyscallStep
from .abb_merge import ABB_MergeStep

from native_step import Step
from native_step import provide_steps as _native_provide

__all__ = ['Step', 'OilStep', 'SyscallStep', 'ABB_MergeStep']

def provide_steps(config: dict):
	for step in  _native_provide(config):
		yield step

	yield OilStep(config)
	yield SyscallStep(config)
	yield ABB_MergeStep(config)
