# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for HyperSSE."""
import sys
from ara.graph import Callgraph, Graph, CFG, MSTGraph, MSTType, StateType
from ara.os import autosar
from ara.stepmanager import StepManager
import logging

from .step import Step # type: ignore
from .option import Option, Integer, String

import graph_tool.util
from graph_tool.draw import graph_draw


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
    graphs: list[Graph] = []
    # cfg: list[CFG] = []
    # callgraph: list[Callgraph] = []
    # os: list[autosar.AUTOSAR] = []

    """
    def _get_initial_state(self):
        os_state = self._graph.os.get_initial_state(self._graph.cfg,
                                                    self._graph.instances)
        cpu_idx = max([x.id for x in os_state.cpus]) + 1
        instances = os_state.instances
        # add interrupts
        for _, irq in instances.get(IRQ):
            # every irq gets an own CPU
            ctx = os_state.context[irq]
            if ctx.status == TaskStatus.running:
                exec_state = CrossExecState.computation
                cur_abb = ctx.abb
            else:
                exec_state = CrossExecState.idle
                cur_abb = None
            irq_cpu = IRQCPU(id=cpu_idx,
                             irq=irq,
                             reference_cpu_id=irq.cpu_id,
                             irq_on=False,
                             control_instance=instances.get_node(irq),
                             abb=cur_abb,
                             call_path=copy(ctx.call_path),
                             exec_state=exec_state,
                             analysis_context=None)
            os_state.cpus[irq_cpu.id] = irq_cpu
            # reassign irq
            irq.cpu_id = irq_cpu.id
            cpu_idx += 1

        # initial sync point
        mstg = self._mstg.g
        sp = mstg.add_vertex()
        mstg.vp.type[sp] = StateType.exit_sync
        mstg.vp.state[sp] = os_state
        self._stats.incr(StateType.exit_sync)
        self._mstg.sync_point_map[sp] = [x.id for x in os_state.cpus]
        self._log.debug(f"Add initial sync point {int(sp)}")

        return sp
    """

    def print_mstg(self, mstg: MSTGraph) -> None:
        log: logging = self._log

        log.error(f"Printing: mstg")
        mstg.list_properties()
        for v in mstg.vertices():
            # {mstg.vp.state[v]}
            if mstg.vp.type[v] == 0:
                print(f"Node: {v} Type=Invalid cpu_id={mstg.vp.cpu_id[v]} bcet={mstg.vp.bcet[v]} wcet={mstg.vp.wcet[v]}")
            else:
                print(f"Node: {v} Type={str(StateType(mstg.vp.type[v]))} cpu_id={mstg.vp.cpu_id[v]} bcet={mstg.vp.bcet[v]} wcet={mstg.vp.wcet[v]}")
        for e in mstg.edges():
            print(f"Edge: {e} Type={str(MSTType(mstg.ep.type[e]))} irq={mstg.ep.irq[e]} cpu_id={mstg.ep.cpu_id[e]} bcet={mstg.ep.bcet[e]} wcet={mstg.ep.wcet[e]}")


    def run(self):
        # checkout get_logger() from ara/util.py
        log: logging = self._log

        if not HyperSSE.systems:
            HyperSSE.systems = self.system_count.get()

        log.warning(f"MultiSSE for dom{HyperSSE.runid} done.")

        # HyperSSE.cfg.append(self._graph.cfg)
        # HyperSSE.callgraph.append(self._graph.callgraph)
        # HyperSSE.os.append(self._graph.os)
        HyperSSE.graphs.append(self._graph)

        HyperSSE.runid += 1

        while HyperSSE.runid < HyperSSE.systems:
            log.warning(f"Starting HyperSSE step - dom{HyperSSE.runid}")

            self._graph = Graph()
            self._graph.os = HyperSSE.graphs[-1].os

            s_manager: StepManager = StepManager(self._graph)
            
            self._step_manager = s_manager

            extra = {'steps': ['MultiSSE', 'DumpCFG', 'HyperSSE'], 'MultiSSE': {'with_times': False, 'dump': True, 'log_level': 'debug'}, "SVFAnalyses": {"log_level": "debug","hide_svf_output": True}, 'HyperSSE': {'dummy_option': 24, "system_count": 2, "dom1" : "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_a2.pi4.ll"}}
            program = {'list_steps': False, 'verbose': False, 'log_level': 'debug', 'dump': False, 'dump_prefix': 'dumps/{step_name}.{uuid}.', 'runtime_stats': False, 'runtime_stats_file': 'logger', 'runtime_stats_format': 'human', 'step_data': False, 'entry_point': '__ara_fake_entry', 'input_file': 'subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_a2.pi4.ll', 'oilfile': '../subprojects/ara/appl/AUTOSAR/singlecore/xen/system2.json', 'step_settings': ['../subprojects/ara/settings/hypersse.json'], 'Werr': False, 'threads': 0, 'trace_algorithm': False, 'os': 'AUTOSAR', 'with_stubs': False}
           
            # extra = {'steps': ['MultiSSE', 'DumpCFG', 'HyperSSE'], 'MultiSSE': {'with_times': False, 'dump': True, 'log_level': 'debug'}, "SVFAnalyses": {"log_level": "debug","hide_svf_output": True}, 'HyperSSE': {'dummy_option': 24, "system_count": 2, "dom1" : "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_b.pi4.ll"}}
            # program = {'list_steps': False, 'verbose': False, 'log_level': 'debug', 'dump': False, 'dump_prefix': 'dumps/{step_name}.{uuid}.', 'runtime_stats': False, 'runtime_stats_file': 'logger', 'runtime_stats_format': 'human', 'step_data': False, 'entry_point': '__ara_fake_entry', 'input_file': 'subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_b.pi4.ll', 'oilfile': '../subprojects/ara/appl/AUTOSAR/singlecore/xen/b_system.json', 'step_settings': ['../subprojects/ara/settings/hypersse.json'], 'Werr': False, 'threads': 0, 'trace_algorithm': False, 'os': 'AUTOSAR', 'with_stubs': False}
            s_manager.execute(program, extra, None)


        # careful, each instance would return here, so call sys.exit(0) at the end
        for i, graph in enumerate(HyperSSE.graphs):
            self.print_mstg(mstg=graph.mstg)
            # graph_draw(graph.mstg, vertex_text=graph.mstg.vertex_index, output=f"dumps/out_{i}.svg")


        log.error("Done with HyperSSE")
        sys.exit(0)
        