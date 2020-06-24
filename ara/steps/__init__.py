import ara.steps.py_logging

def provide_steps():
    from .step import provide_steps as _native_provide
    from .abb_merge import ABBMerge
    from .call_graph import CallGraph
    from .cfg_optimize import CFGOptimize
    from .cfg_stats import CFGStats
    from .dummy import Dummy
    from .generator import Generator
    from .load_oil import LoadOIL
    from .printer import Printer
    from .sse import InstanceGraph, InteractionAnalysis, MultiSSE
    from .syscall import Syscall
    from .sysfuncts import SysFuncts
    from .value_analysis import ValueAnalysis

    for step in _native_provide():
        yield step

    yield ABBMerge()
    yield CallGraph()
    yield CFGOptimize()
    yield CFGStats()
    yield Dummy()
    yield Generator()
    yield InstanceGraph()
    yield InteractionAnalysis()
    yield LoadOIL()
    yield Printer()
    yield MultiSSE()
    yield Syscall()
    yield SysFuncts()
    yield ValueAnalysis()
