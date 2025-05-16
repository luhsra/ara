# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for HyperSSE."""
import sys
from ara.graph import ABBType, Graph, CFG, MSTGraph, MSTType, NodeLevel, StateType, HSTGraph, HSTType, HyperStateType
from ara.os.autosar import AUTOSAR
from ara.os.os_base import OSState
from ara.stepmanager import StepManager
import logging

from ara.os.xen import XEN

from .step import Step # type: ignore
from .option import Option, Integer, String, List

from graph_tool.draw import graph_draw


#class HyperSSE(MultiSSE):
class HyperSSE(Step):
    """Provides analysis of inter-vm communication."""
    system_count: Option = Option(name="system_count",
                          help="Number of systems that should be analysed together.",
                          ty=Integer(),
                          default_value=1)
    
    # ara cli paramters are ignored for now
    dom_files: Option = Option(name="dom_files",
                         help="Path of list of dom ll.",
                         ty=List(String))
    dom_oils: Option = Option(name="dom_oils",
                         help="Path of list of dom oil.",
                         ty=List(String))


    # used for dom0
    def get_single_dependencies(self):
        # first run MultiSSE, afterwards cleanup svf datastructures for next run
        #return ["MultiSSE", "SVFReset"]
        return []
        # return ["MultiSSE"]
    
    runid: int = 0
    systems: int|None = None
    graphs: list[Graph] = []
    done: bool = False
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

    def print_hstg(self, hstg: HSTGraph) -> None:
        log: logging = self._log

        log.warning(f"Printing: hstg")
        hstg.list_properties()
        for v in hstg.vertices():
            # {hstg.vp.state[v]}
            if hstg.vp.type[v] == 0:
                print(f"Node: {v} Type=Invalid domain_id={hstg.vp.domain_id[v]} cpu_id={hstg.vp.cpu_id[v]} bcet={hstg.vp.bcet[v]} wcet={hstg.vp.wcet[v]}")
            else:
                print(f"Node: {v} Type={str(HyperStateType(hstg.vp.type[v]))} domain_id={hstg.vp.domain_id[v]} cpu_id={hstg.vp.cpu_id[v]} bcet={hstg.vp.bcet[v]} wcet={hstg.vp.wcet[v]}")
        for e in hstg.edges():
            print(f"Edge: {e} Type={str(HSTType(hstg.ep.type[e]))} irq={hstg.ep.irq[e]} domain_id={hstg.ep.domain_id[e]} cpu_id={hstg.ep.cpu_id[e]} bcet={hstg.ep.bcet[e]} wcet={hstg.ep.wcet[e]}")

    def build_hstg(self) -> HSTGraph:

        hstg = HSTGraph()
        hstg.vp.domain_id[0] = -1

        for i, graph in enumerate(HyperSSE.graphs):
            mstg = graph.mstg
            hstg.add_mstg(mstg=mstg)

            # self.print_mstg(mstg=mstg)
            # graph_draw(mstg, vertex_text=mstg.vertex_index, output=f"dumps/out_{i}.svg")

        self.print_hstg(hstg=hstg)

        # print hstg
        self._graph.hstg = hstg
        file_name = f"{self.dump_prefix.get()}hstg.dot"
        self._step_manager.chain_step({"name": "Printer",
                                        "dot": file_name,
                                        "graph_name": "HSTG",
                                        "subgraph": 'hstg'})
        return hstg

    def print_cfg_nodes(self, cfg: CFG) -> None:
        log: logging = self._log

        log.warning(f"Printing: cfg")
        cfg.list_properties()
        for v in cfg.vertices():
            print(f"Node: {v} {str(ABBType(cfg.vp.type[v]))} {str(NodeLevel(cfg.vp.level[v]))}")
            #Type={str(HyperStateType(cfg.vp.type[v]))} domain_id={cfg.vp.domain_id[v]} cpu_id={hstg.vp.cpu_id[v]} bcet={hstg.vp.bcet[v]} wcet={hstg.vp.wcet[v]}")
        for e in cfg.edges():
            print(f"Edge: {e} is_entry: {cfg.ep.is_entry[e]}")
            #Type={str(HSTType(cfg.ep.type[e]))} irq={cfg.ep.irq[e]} domain_id={cfg.ep.domain_id[e]} cpu_id={hstg.ep.cpu_id[e]} bcet={hstg.ep.bcet[e]} wcet={hstg.ep.wcet[e]}")


    def run(self):
        # checkout get_logger() from ara/util.py
        log: logging = self._log

        if not HyperSSE.systems:
            HyperSSE.systems = self.system_count.get()

        # log.warning(f"MultiSSE for dom{HyperSSE.runid} done.")

        # HyperSSE.cfg.append(self._graph.cfg)
        # HyperSSE.callgraph.append(self._graph.callgraph)
        # HyperSSE.os.append(self._graph.os)
        # HyperSSE.graphs.append(self._graph)

        if HyperSSE.runid != 0:

            HyperSSE.graphs.append(self._graph)

        while HyperSSE.runid < HyperSSE.systems:
            log.warning(f"Starting HyperSSE step - dom{HyperSSE.runid}")

            self._graph = Graph()
            self._graph.os = AUTOSAR

            # geht nicht
            # self._graph._graph_data = HyperSSE.graphs[-1]._graph_data

            input_file = self.dom_files.get()[HyperSSE.runid]
            oilfile = self.dom_oils.get()[HyperSSE.runid]
            log.warning(f"Found {input_file}, {oilfile}")

            program = self._step_manager._config.program
            extra = self._step_manager._config.extra

            # log.error(f"Olf config: {self._step_manager._config}")
            s_manager: StepManager = StepManager(self._graph)
            
            self._step_manager = s_manager

            # add new files for new dom
            program["input_file"] = input_file
            program["oilfile"] = oilfile
            extra["HyperSSE"]["dom_files"] = self.dom_files.get()
            extra["HyperSSE"]["oil_files"] = self.dom_oils.get()
            extra["DumpCFG"] = {}
            extra["DumpCFG"]["dot"] = "dom" + str(HyperSSE.runid)
            extra["DumpCFG"]["add_legend"] = False
            extra["DumpInstances"] = {}
            extra["DumpInstances"]["dot"] = "dom" + str(HyperSSE.runid)
            extra["MultiSSE"]["file_name_appendix"] = "dom" + str(HyperSSE.runid)
            extra["MultiSSE"]["add_legend"] = False

            # readd steps that are completed
            extra["steps"] = ['MultiSSE', 'DumpCFG', 'DumpInstances', 'SVFReset', 'HyperSSE']
            # reset entry_points
            program["entry_point"] = "main" 

            HyperSSE.runid += 1
           
            # log.error(f"New config: {program}, {extra}")
            
            s_manager.execute(program, extra, None)


        # careful, each instance would return here, so exit unless we are the first instance
        if HyperSSE.done:
            return

        # MERGING:
        """
        merged_cfg = CFG()
        merged_instance = InstanceGraph()

        for i, graph in enumerate(HyperSSE.graphs):
            merged_cfg.add_cfg(cfg=graph.cfg, id=i)
            merged_instance.add_instance(instance=graph.instances, id=i)

        self.print_cfg_nodes(merged_cfg)

        # self._graph.cfg = merged_cfg
        # self._graph.instances = merged_instance

        self._step_manager.chain_step({"name": "DumpCFG", "dot": "merged", "add_legend": True})
        self._step_manager.chain_step({"name": "DumpInstances", "dot": "merged"})
        """

        # self._graph = HyperSSE.graphs[0]
        self._graph.os = XEN
        XEN.graph_list = HyperSSE.graphs

        for graph in HyperSSE.graphs:
            XEN.system_types.append(AUTOSAR)
            graph.cfg.name = "dom" + str(XEN.system_count)
            graph.instances.name = "dom" + str(XEN.system_count)
            XEN.cfg_list.append(graph.cfg)
            XEN.instances_list.append(graph.instances)
            XEN.system_count += 1


        OSState.reset_id()

        self._step_manager.chain_step({"name": "MultiSSE", "with_times": False, "dump": True, 
                                       "log_level": "debug", "hyper_sse": True, "file_name_appendix": "hyper", "add_legend": False})

        log.error("Done with single MultiSSEs, starting HyperSSE MultiSSE now!")
        HyperSSE.done = True
