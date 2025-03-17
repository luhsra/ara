# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for HyperSSE."""
from ara.graph import Callgraph, Graph, CFG
from ara.os import autosar
from ara.stepmanager import StepManager

from .step import Step
from .option import Option, Integer

import graph_tool
import graph_tool.util


#class HyperSSE(MultiSSE):
class HyperSSE(Step):

    runid = 0

    """Provides analysis of inter-vm communication."""
    dummy_option = Option(name="dummy_option",
                          help="An option to demonstrate options.",
                          ty=Integer())

    # TODO
    #def get_dependencies(self, _):
    #    return []
        # return ["MultiSSE"]
    def get_single_dependencies(self):
        return ["MultiSSE"]
    

    class dummyCFG(graph_tool.Graph):
        def __init__(self, a=None):
            super().__init__()
            self.vertex_properties["function"] = self.new_vp("object")

        
        # def save(self, file_name, fmt="auto"):
        #     super().save(file_name, fmt="auto")
        #     print("save")

        
        # def load(self, file_name, fmt="auto", ignore_vp=None, ignore_ep=None, ignore_gp=None):
        #     super().load(file_name, fmt="auto", ignore_vp=None, ignore_ep=None, ignore_gp=None)
        #     print("load")
        #     self.a = 4
        
        # def getstate(self):
        #     print(f"save a: {self.a}")
        #     return self.a
        
        # def setstate(self, a):
        #     print(f"load a: {self.a}")
        #     self.__init__(a)

    def run(self):

        log = self._log

        log.info("Starting HyperSSE step.")
        opt = self.dummy_option.get()
        if opt:
            log.info(f"Option is {opt}.")

        # extract graphs
        cfg: CFG = self._graph.cfg
        callgraph: Callgraph = self._graph.callgraph
        os: autosar.AUTOSAR = self._graph.os
        old_graph: Graph = self._graph


        self._graph: Graph = Graph()
        self._graph.os = old_graph.os

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
        

        # SAVE CFG
        #with open('cfg.pkl', 'wb') as file:
        #    dill.dump(cfg, file)
        #cfg.save("cfg.gt", fmt="gt")



        # orig = HyperSSE.dummyCFG()
        # v1 = orig.add_vertex()
        # v2 = orig.add_vertex()
        # self._log.error(f"orig: {orig}")
                        
        # orig.save("origg.gt", fmt="gt")

        # new = HyperSSE.dummyCFG()
        # new.load("origg.gt", fmt="gt")
        # self._log.error(f"new: {new}/{new.list_properties()}")
        # self._log.error(f"orig: {orig}{orig.list_properties()}")
        

        # GRAPH WITH PROPERTIES
        # orig = graph_tool.Graph()
        # v1 = orig.add_vertex()
        # v2 = orig.add_vertex()
        # orig.vertex_properties["test"] = orig.new_vp("bool")
        # self._log.error(f"orig: {orig}")
                        
        # orig.save("origg.gt", fmt="gt")

        # new = graph_tool.Graph()
        # new.load("origg.gt", fmt="gt")
        # l = graph_tool.load_graph("origg.gt", fmt="gt")
        # self._log.error(f"l: {l}/{l.list_properties()}")
        # self._log.error(f"new: {new}/{new.list_properties()}")
        # self._log.error(f"orig: {orig}{orig.list_properties()}")


        # loadoil()
