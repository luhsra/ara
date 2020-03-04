from .abb_merge import ABBMerge
from .call_graph import CallGraph
from .cfg_stats import CFGStats
from .dummy import Dummy
from .generator import Generator
from .oil import OilStep
from .printer import Printer
from .sse import InstanceGraph, InteractionAnalysis
from .syscall import Syscall
from .value_analysis import ValueAnalysis

import py_logging

from native_step import Step
from native_step import provide_steps as _native_provide


def provide_steps():
    for step in _native_provide():
        yield step

    yield ABBMerge()
    yield CallGraph()
    yield CFGStats()
    yield Dummy()
    yield Generator()
    yield OilStep()
    yield Printer()
    yield InstanceGraph()
    yield InteractionAnalysis()
    yield Syscall()
    yield ValueAnalysis()
