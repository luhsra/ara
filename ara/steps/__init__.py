import ara.steps.py_logging

def provide_steps():
    from .step import provide_steps as _native_provide
    from .callgraph_stats import CallGraphStats
    from .classify_specializations_freertos import ClassifySpecializationsFreeRTOS
    from .create_abbs import CreateABBs
    from .cfg_optimize import CFGOptimize
    from .cfg_stats import CFGStats
    from .dummy import Dummy
    from .generator import Generator
    from .icfg import ICFG
    from .load_oil import LoadOIL
    from .manual_corrections import ManualCorrections
    from .printer import Printer
    from .recursive_functions import RecursiveFunctions
    from .register_task_entry import RegisterTaskEntry
    from .sia import SIA, InteractionAnalysis
    from .multisse import MultiSSE
    from .syscall import Syscall
    from .sysfuncts import SysFuncts
    from .system_relevant_functions import SystemRelevantFunctions

    for step in _native_provide():
        yield step

    yield CFGOptimize
    yield CFGStats
    yield CreateABBs
    yield CallGraphStats
    yield ClassifySpecializationsFreeRTOS
    yield Dummy
    yield Generator
    yield ICFG
    yield SIA
    yield InteractionAnalysis
    yield LoadOIL
    yield ManualCorrections
    yield MultiSSE
    yield Printer
    yield RecursiveFunctions
    yield RegisterTaskEntry
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
