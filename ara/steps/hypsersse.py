# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""HyperSSE Analysis"""
from ara.graph import Graph
from ara.os.autosar import AUTOSAR
from ara.os.os_base import reset_id
from ara.stepmanager import StepManager
import logging

from ara.os.xen import XEN

from .step import Step # type: ignore
from .option import Option, Integer, String, List, Bool

class HyperSSE(Step):
    """Provides analysis of multiple operating systems on a shared hypervisor, currently Xen is supported."""
    system_count: Option = Option(name="system_count",
                          help="Number of systems that should be analysed together.",
                          ty=Integer(),
                          default_value=1)
    do_timings: Option = Option(name="do_timings",
                          help="If WCET/BCET timing information on ABBs should be used.",
                          ty=Bool(),
                          default_value=True)
    testname: Option = Option(name="testname",
                          help="How printed graphs should be named.",
                          ty=String(),
                          default_value="testsg")
    
    # This steps ignores the ara cli paramters that other steps us, instead this options are used
    dom_files: Option = Option(name="dom_files",
                         help="Path of list of dom ll.",
                         ty=List(String))
    dom_oils: Option = Option(name="dom_oils",
                         help="Path of list of dom oil.",
                         ty=List(String))

    def get_single_dependencies(self):
        return []
    
    # Tracks how many guests systems are analysed 
    runid: int = 0
    # Stores the graph object from each guest
    graphs: list[Graph] = []
    # Used to check if all guests are analysed on their own
    done: bool = False

    def run(self):
        # See get_logger() from ara/util.py
        log: logging = self._log

        # If this is not the first run store the previous graph
        if HyperSSE.runid != 0:
            HyperSSE.graphs.append(self._graph)

        # Iterate guest systems
        while HyperSSE.runid < self.system_count.get():
            log.info(f"Starting HyperSSE step - dom{HyperSSE.runid}")

            # Create a new root graph object
            self._graph = Graph()

            # For now only AUTOSAR
            self._graph.os = AUTOSAR

            input_file = self.dom_files.get()[HyperSSE.runid]
            oilfile = self.dom_oils.get()[HyperSSE.runid]
            log.debug(f"Found: {input_file.removeprefix('subprojects/ara/appl/AUTOSAR/')}")
            log.debug(f"Found: {oilfile.removeprefix('../subprojects/ara/appl/AUTOSAR/')}")

            # Copy old config
            program = self._step_manager._config.program
            extra = self._step_manager._config.extra

            s_manager: StepManager = StepManager(self._graph)
            self._step_manager = s_manager

            # Modify old config
            program["input_file"] = input_file
            program["oilfile"] = oilfile
            extra["HyperSSE"]["dom_files"] = self.dom_files.get()
            extra["HyperSSE"]["oil_files"] = self.dom_oils.get()
            extra["SystemRelevantFunctions"] = {}
            extra["SystemRelevantFunctions"]["xen_syscall"] = True
            extra["SysFuncts"] = {}
            extra["SysFuncts"]["xen_syscall"] = True
            extra["DumpCFG"] = {}
            extra["DumpCFG"]["dot"] = str(self.testname.get()) + ".dom" + str(HyperSSE.runid)
            extra["DumpCFG"]["add_legend"] = False
            extra["DumpInstances"] = {}
            extra["DumpInstances"]["dot"] = str(self.testname.get()) + ".dom" + str(HyperSSE.runid)
            extra["MultiSSE"]["file_name"] = str(self.testname.get()) + ".dom" + str(HyperSSE.runid)
            extra["MultiSSE"]["add_legend"] = False
            extra["MultiSSE"]["with_times"] = self.do_timings.get()
            extra["ApplyTimings"] = {}
            extra["ApplyTimings"]["timings"] = "BB"
            extra["logger"] = {}
            extra["logger"]["AUTOSAR"] = "warning"
            extra["LoadOIL"] = {}
            extra["LoadOIL"]["log_level"] = "error"

            # Readadd all steps, end with returning to HyperSSE
            extra["steps"] = ['ApplyTimings', 'MultiSSE', 'DumpCFG', 'DumpInstances', 'SVFReset', 'HyperSSE']
            # Reset entry_points
            program["entry_point"] = "main" 

            HyperSSE.runid += 1
            s_manager.execute(program, extra, None)

        # Each instance would return here, so exit unless we are the first/root instance
        if HyperSSE.done:
            return
        
        # Prepare a new Graph for the Xen MultiSSE 
        self._step_manager._graph = Graph()
        self._step_manager._graph.os = XEN
        self._step_manager._graph.name = "Graph-Xen"
        XEN.graph_list = HyperSSE.graphs

        for graph in HyperSSE.graphs:
            XEN.system_types.append(AUTOSAR)
            graph.name = "Graph-dom-" + str(XEN.system_count)
            graph.cfg.name = "CFG-dom-" + str(XEN.system_count)
            XEN.cfg_list.append(graph.cfg)
            graph.instances.name = "Inst-dom-" + str(XEN.system_count)
            XEN.instances_list.append(graph.instances)
            XEN.system_count += 1

        # Reset to OSState Counter back to 0
        reset_id()

        # Call another MultiSSE once this step is finished
        self._step_manager.chain_step({"name": "MultiSSE", "with_times": self.do_timings.get(), "dump": True, 
                                       "log_level": "debug", "hyper_sse": True, "file_name": str(self.testname.get()), "add_legend": False})

        log.warning("Done with single MultiSSEs, starting HyperSSE MultiSSE now!")
        HyperSSE.done = True
