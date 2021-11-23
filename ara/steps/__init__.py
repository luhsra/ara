import ara.steps.py_logging


def provide_steps():
    from .step import provide_steps as _native_provide
    from .callgraph_stats import CallGraphStats
    from .classify_specializations_freertos import ClassifySpecializationsFreeRTOS
    from .create_abbs import CreateABBs
    from .cfg_optimize import CFGOptimize
    from .cfg_stats import CFGStats
    from .dummy import Dummy
    from .dump_cfg import DumpCFG
    from .generator import Generator
    from .icfg import ICFG
    from .load_oil import LoadOIL
    from .lock_elision import LockElision
    from .manual_corrections import ManualCorrections
    from .printer import Printer
    from .recursive_functions import RecursiveFunctions
    from .reduce_sstg import ReduceSSTG
    from .register_task_entry import RegisterTaskEntry
    from .sia import SIA, InteractionAnalysis
    from .multisse import MultiSSE
    from .sse import SSE
    from .syscall import Syscall
    from .sysfuncts import SysFuncts
    from .system_relevant_functions import SystemRelevantFunctions

    for step in _native_provide():
        yield step

    yield CFGOptimize
    yield CFGStats
    yield CallGraphStats
    yield ClassifySpecializationsFreeRTOS
    yield CreateABBs
    yield Dummy
    yield DumpCFG
    yield Generator
    yield ICFG
    yield InteractionAnalysis
    yield LoadOIL
    yield LockElision
    yield ManualCorrections
    yield MultiSSE
    yield Printer
    yield RecursiveFunctions
    yield ReduceSSTG
    yield RegisterTaskEntry
    yield SIA
    yield SSE
    yield SysFuncts
    yield Syscall
    yield SystemRelevantFunctions


def get_native_component(name: str):
    # direct import would result in dependency conflicts
    from .step import (ValueAnalyzer, ValueAnalyzerResult, ValuesUnknown,
                       ConnectionStatusUnknown)
    components = {"ValueAnalyzer": ValueAnalyzer,
                  "ValueAnalyzerResult": ValueAnalyzerResult,
                  "ValuesUnknown": ValuesUnknown,
                  "ConnectionStatusUnknown": ConnectionStatusUnknown}
    return components[name]
