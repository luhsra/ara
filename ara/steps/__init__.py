# SPDX-FileCopyrightText: 2019 Benedikt Steinmeier
# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Fredo Nowak
# SPDX-FileCopyrightText: 2020 Kenny Albes
# SPDX-FileCopyrightText: 2020 Manuel Breiden
# SPDX-FileCopyrightText: 2020 Yannick Loeck
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Lukas Berg
# SPDX-FileCopyrightText: 2022 Domenik Kuhn
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

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
    from .dump_callgraph import DumpCallgraph
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
    from .mstg_stats import MSTGStats
    from .multisse import MultiSSE
    from .printer import Printer
    from .reduce_sstg import ReduceSSTG
    from .register_task_entry import RegisterTaskEntry
    from .sia import SIA, InteractionAnalysis
    from .sse import SSE
    from .sstg_stats import SSTGStats
    from .svfg_stats import SVFGStats
    from .syscall import Syscall
    from .sysfuncts import SysFuncts
    from .system_relevant_functions import SystemRelevantFunctions
    from .zephyr_static_post import ZephyrStaticPost
    from .posix_init import POSIXInit

    for step in _native_provide():
        yield step

    yield ApplyTimings
    yield CFGOptimize
    yield CFGStats
    yield CallGraphStats
    yield ClassifySpecializationsFreeRTOS
    yield CreateABBs
    yield Dummy
    yield DumpCallgraph
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
    yield MSTGStats
    yield MultiSSE
    yield POSIXInit
    yield Printer
    yield ReduceSSTG
    yield RegisterTaskEntry
    yield SIA
    yield SSE
    yield SSTGStats
    yield SVFGStats
    yield SysFuncts
    yield Syscall
    yield SystemRelevantFunctions
    yield ZephyrStaticPost


def get_native_component(name: str):
    # direct import would result in dependency conflicts
    from .step import (ValueAnalyzer, ValueAnalyzerResult, ValuesUnknown,
                       ConnectionStatusUnknown)
    components = {"ValueAnalyzer": ValueAnalyzer,
                  "ValueAnalyzerResult": ValueAnalyzerResult,
                  "ValuesUnknown": ValuesUnknown,
                  "ConnectionStatusUnknown": ConnectionStatusUnknown}
    return components[name]
