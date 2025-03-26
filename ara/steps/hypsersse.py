# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for HyperSSE."""
import sys
from ara.graph import Callgraph, Graph, CFG
from ara.os import autosar
from ara.stepmanager import StepManager
import logging

from .step import Step # type: ignore
from .option import Option, Integer, String

import graph_tool
import graph_tool.util


#class HyperSSE(MultiSSE):
class HyperSSE(Step):
    """Provides analysis of inter-vm communication."""
    system_count: Option = Option(name="system_count",
                          help="Number of systems that should be analysed together.",
                          ty=Integer(),
                          default_value=1)
    # dom0 is given by ara cli parameters
    dom1: Option = Option(name="dom1",
                         help="Path of dom1 ll.",
                         ty=String())

    # used for dom0
    def get_single_dependencies(self):
        # first run MultiSSE, afterwards cleanup svf datastructures for next run
        return ["MultiSSE", "SVFReset"]
    
    runid: int = 0
    systems: int|None = None
    cfg: list[CFG] = []
    callgraph: list[Callgraph] = []
    os: list[autosar.AUTOSAR] = []

    def run(self):
        log: logging = self._log

        if not HyperSSE.systems:
            HyperSSE.systems = self.system_count.get()

        log.warning(f"MultiSSE for dom{HyperSSE.runid} done.")

        HyperSSE.cfg.append(self._graph.cfg)
        HyperSSE.callgraph.append(self._graph.callgraph)
        HyperSSE.os.append(self._graph.os)

        HyperSSE.runid += 1

        while HyperSSE.runid < HyperSSE.systems:
            log.warning(f"Starting HyperSSE step - dom{HyperSSE.runid}")

            self._graph = Graph()
            self._graph.os = HyperSSE.os[-1]

            s_manager: StepManager = StepManager(self._graph)
            
            self._step_manager = s_manager

            extra = {'steps': ['MultiSSE', 'DumpCFG', 'HyperSSE'], 'MultiSSE': {'with_times': False, 'dump': True, 'log_level': 'debug'}, "SVFAnalyses": {"log_level": "debug","hide_svf_output": True}, 'HyperSSE': {'dummy_option': 24, "system_count": 2, "dom1" : "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_b.pi4.ll"}}
            program = {'list_steps': False, 'verbose': False, 'log_level': 'debug', 'dump': False, 'dump_prefix': 'dumps/{step_name}.{uuid}.', 'runtime_stats': False, 'runtime_stats_file': 'logger', 'runtime_stats_format': 'human', 'step_data': False, 'entry_point': '__ara_fake_entry', 'input_file': 'subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_b.pi4.ll', 'oilfile': '../subprojects/ara/appl/AUTOSAR/singlecore/xen/b_system.json', 'step_settings': ['../subprojects/ara/settings/hypersse.json'], 'Werr': False, 'threads': 0, 'trace_algorithm': False, 'os': 'AUTOSAR', 'with_stubs': False}
            s_manager.execute(program, extra, None)

        # careful, each instance would return here, so call sys.exit(0) at the end
        log.error(HyperSSE.cfg)

        log.error("Done with HyperSSE")
        sys.exit(0)
        

