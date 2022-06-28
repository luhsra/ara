import ara.steps.py_logging


def provide_steps():
    from .step import provide_steps as _native_provide

    from .apply_timings import ApplyTimings
    from .callgraph_stats import CallGraphStats
    from .cfg_optimize import CFGOptimize
    from .cfg_stats import CFGStats
    from .classify_specializations_freertos import ClassifySpecializationsFreeRTOS
    from .create_abbs import CreateABBs
    from .dummy import Dummy
    from .dump_cfg import DumpCFG
    from .dump_instances import DumpInstances
    from .dump_sstg import DumpSSTG
    from .fake_timings import FakeTimings
    from .generator import Generator
    from .icfg import ICFG
    from .instance_graph_stats import InstanceGraphStats
    from .ipi_avoidance import IPIAvoidance
    from .load_oil import LoadOIL
    from .lock_elision import LockElision
    from .manual_corrections import ManualCorrections
    from .mark_loop_head import MarkLoopHead
    from .multisse import MultiSSE
    from .printer import Printer
    from .recursive_functions import RecursiveFunctions
    from .reduce_sstg import ReduceSSTG
    from .register_task_entry import RegisterTaskEntry
    from .sia import SIA, InteractionAnalysis
    from .sse import SSE
    from .sstg_stats import SSTGStats
    from .syscall import Syscall
    from .sysfuncts import SysFuncts
    from .system_relevant_functions import SystemRelevantFunctions

    for step in _native_provide():
        yield step

    yield ApplyTimings
    yield CFGOptimize
    yield CFGStats
    yield CallGraphStats
    yield ClassifySpecializationsFreeRTOS
    yield CreateABBs
    yield Dummy
    yield DumpCFG
    yield DumpInstances
    yield DumpSSTG
    yield FakeTimings
    yield Generator
    yield ICFG
    yield IPIAvoidance
    yield InstanceGraphStats
    yield InteractionAnalysis
    yield LoadOIL
    yield LockElision
    yield ManualCorrections
    yield MarkLoopHead
    yield MultiSSE
    yield Printer
    yield RecursiveFunctions
    yield ReduceSSTG
    yield RegisterTaskEntry
    yield SIA
    yield SSE
    yield SSTGStats
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
