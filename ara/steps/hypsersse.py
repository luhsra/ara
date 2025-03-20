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
    dummy_option: Option = Option(name="dummy_option",
                          help="An option to demonstrate options.",
                          ty=Integer())
    system_count: Option = Option(name="system_count",
                          help="Number of systems that should be analysed together.",
                          ty=Integer())
    # dom0 is given by ara cli parameters
    dom1: Option = Option(name="dom1",
                         help="Path of dom1 ll.",
                         ty=String())

    # used for dom0
    def get_single_dependencies(self):
        return ["MultiSSE"]
    
    runid: int = 0
    systems: int|None = None
    cfg: list[CFG] = []
    callgraph: list[Callgraph] = []
    os: list[autosar.AUTOSAR] = []

    def run(self):
        log: logging = self._log

        if not HyperSSE.systems:
            HyperSSE.systems = self.system_count.get()
        if not HyperSSE.systems:
            log.error(f"system_count not set, aborting!")
            sys.exit(0)

        log.warning(f"MultiSSE for dom{HyperSSE.runid} done.")

        HyperSSE.cfg.append(self._graph.cfg)
        HyperSSE.callgraph.append(self._graph.callgraph)
        HyperSSE.os.append(self._graph.os)

        HyperSSE.runid += 1

        while HyperSSE.runid < HyperSSE.systems:
            log.warning(f"Starting HyperSSE step - dom{HyperSSE.runid}")

            self._graph = Graph()
            self._graph.os = HyperSSE.os[-1]

            # hier problem bei svf_analyses
            s_manager: StepManager = StepManager(self._graph)
            
            self._step_manager = s_manager

            # hier problem bei IRReader assertion
            # s_manager = self._step_manager
            # s_manager.clear_history()
            # s_manager._graph = self._graph

            # läuft durch aber falsch
            # s_manager = self._step_manager

            extra = {'steps': ['MultiSSE', 'DumpCFG', 'HyperSSE'], "SVFAnalyses": {
		"dump": True,
		"log_level": "debug"
	},'MultiSSE': {'with_times': False, 'dump': True, 'log_level': 'debug'}, 'HyperSSE': {'dummy_option': 24, "system_count": 2, "dom1" : "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_b.pi4.ll"}}
            program = {'list_steps': False, 'verbose': False, 'log_level': 'debug', 'dump': False, 'dump_prefix': 'dumps/{step_name}.{uuid}.', 'runtime_stats': False, 'runtime_stats_file': 'logger', 'runtime_stats_format': 'human', 'step_data': False, 'entry_point': '__ara_fake_entry', 'input_file': 'subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_b.pi4.ll', 'oilfile': '../subprojects/ara/appl/AUTOSAR/singlecore/xen/b_system.json', 'step_settings': ['../subprojects/ara/settings/hypersse.json'], 'Werr': False, 'threads': 0, 'trace_algorithm': False, 'os': 'AUTOSAR', 'with_stubs': False}
            s_manager.execute(program, extra, None)


        log.error(HyperSSE.cfg)

        sys.exit(0)
        # extract graphs
        cfg: CFG = self._graph.cfg
        callgraph: Callgraph = self._graph.callgraph
        os: autosar.AUTOSAR = self._graph.os
        old_graph: Graph = self._graph


        #s_manager: StepManager = StepManager(self._graph)
        #log.error(s_manager._step_history)

        s_manager = self._step_manager

        #s_manager.clear_history()
        #log.error(s_manager._step_history)
        #log.error(s_manager._config)

        #s_manager._config = self._step_manager._config
        log.error(HyperSSE.runid)
        HyperSSE.runid += 1
        extra = {'steps': ['MultiSSE', 'DumpCFG', 'HyperSSE'], 'MultiSSE': {'with_times': False, 'dump': True, 'log_level': 'debug'}, 'HyperSSE': {'dummy_option': 24}}
        #s_manager.init_execution(program_config=self._step_manager._config.program, extra_config=extra, esteps=None)

        s_manager._config.program["input_file"] = "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_b.pi4.ll"
        #log.error(s_manager._config)

        #s_manager._graph = self._graph
        s_manager.execute(s_manager._config.program, extra, None)
        #s_manager._execute_steps_with_deps(s_manager._step_history)


        new_graph = Graph()
        cfg2 = new_graph.cfg

        log.error("donew")
        

