# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""HyperSSE Analysis"""
from ara.graph import Graph
from ara.os.autosar import AUTOSAR
from ara.os.zephyr import Zephyr
from ara.os.bare_metal import BareMetal
from ara.os.os_base import reset_id
from ara.os.os_util import _clear_cache
from ara.stepmanager import StepManager
import logging

from ara.os.xen import XEN

from .step import Step # type: ignore
from .option import Option, String, List, Bool

class HyperSSE(Step):
    """Provides analysis of multiple operating systems on a shared hypervisor, currently Xen is supported."""

    do_timings: Option = Option(name="do_timings",
                          help="If WCET/BCET timing information on ABBs should be used.",
                          ty=Bool(),
                          default_value=True)
    testname: Option = Option(name="testname",
                          help="How printed graphs should be named.",
                          ty=String(),
                          default_value="testsg")
    do_stats: Option = Option(name="do_stats",
                          help="If *STG stats should be collected.",
                          ty=Bool(),
                          default_value=False)
    
    # Syntax is: OSName;config1;config2;OSNAME ...
    guests: Option = Option(name="guests",
                         help="Data about each guest systems, the first entry is always the name of the OS.",
                         ty=String())

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

        # clear valueanalyser cache from os_util.py cache!
        _clear_cache()

        # Iterate one guest systems, which calls another HyperSSE round to here
        if self.guests.get():
            guests = self.guests.get().split(';')
            log.info(f"Starting HyperSSE step - dom{HyperSSE.runid}")

            # Create a new root graph object
            self._graph = Graph()
            # Copy old config
            program = self._step_manager._config.program
            extra = self._step_manager._config.extra

            s_manager: StepManager = StepManager(self._graph)
            self._step_manager = s_manager
            match guests[0]:
                case "Autosar":
                    self._graph.os = AUTOSAR
                    log.debug(f"Found: {guests[1].removeprefix('subprojects/ara/appl/AUTOSAR/')}")
                    log.debug(f"Found: {guests[2].removeprefix('../subprojects/ara/appl/AUTOSAR/')}")

                    program["input_file"] = guests[1]
                    program["oilfile"] = guests[2]
                    extra["LoadOIL"] = {"log_level": "error"}

                    # Remove first 3 elements
                    guests = guests[3:] 

                    if self.do_timings.get():
                        extra["MultiSSE"]["with_times"] = True
                        extra["ApplyTimings"] = {"timings":"BB"}

                        # Readadd all steps, end with returning to HyperSSE
                        extra["steps"] = ['ApplyTimings', 'MultiSSE', 'DumpCFG', 'DumpInstances', 'SVFReset', 'HyperSSE']
                    else:
                        extra["steps"] = ['MultiSSE', 'DumpCFG', 'DumpInstances', 'SVFReset', 'HyperSSE']


                case "Zephyr":
                    # other Zepyhr build also adds --with-stubs and --va-corrections with an emtpy json file
                    self._graph.os = Zephyr
                    program["input_file"] = guests[1]

                    trimmed = guests[1].removesuffix(".ll")
                    extra["ZephyrStaticPost"] = {"kconfigfile": trimmed + ".config"}
                    extra["LoadKernelLL"] = {"kernel_ll": trimmed + "-kernel.ll"}
                    extra["RemoveSysfuncBody"] = {"drop_llvm_suffix": True, "disable": False}
                    extra["ZephyrStatic"] = {"log_level": "debug"}
                    extra["SIA"] = {"xen_syscall": True}

                    if self.do_timings.get():
                        extra["MultiSSE"]["with_times"] = True
                        extra["ApplyTimings"] = {"timings":"BB"}
                        
                        extra["steps"] = ['MergeStructs', 'RemoveSysfuncBody', 'ZephyrThreadEntry', 'SIA', "LoadKernelLL",
                                      'DumpCFG', 'DumpInstances', 'ApplyTimings', 'SSE', 'SVFReset', 'HyperSSE']
                    else:
                        extra["steps"] = ['MergeStructs', 'RemoveSysfuncBody', 'ZephyrThreadEntry', 'SIA', "LoadKernelLL",
                                      'DumpCFG', 'DumpInstances', 'SSE', 'SVFReset', 'HyperSSE']

                    log.warning(f"Starting Zephyr: {guests[1]}")

                    # Remove first 2 elements
                    guests = guests[2:]

                case "BareMetal":
                    self._graph.os = BareMetal
                    log.info(f"Found bareMetal: {guests[1]}")

                    program["input_file"] = guests[1]

                    # Remove first 2 elements
                    guests = guests[2:] 

                    if self.do_timings.get():
                        extra["MultiSSE"]["with_times"] = True
                        extra["ApplyTimings"] = {"timings":"BB"}

                        # Readadd all steps, end with returning to HyperSSE
                        # Somehow we need to include Syscall here!
                        extra["steps"] = ['ApplyTimings', 'Syscall', 'MultiSSE', 'DumpCFG', 'DumpInstances', 'SVFReset', 'HyperSSE']
                    else:
                        # Somehow we need to include Syscall here!
                        extra["steps"] = ['Syscall', 'MultiSSE', 'DumpCFG', 'DumpInstances', 'SVFReset', 'HyperSSE']


                case _:
                    log.error(f"Unkown guest OS: {guests[0]}")
                    exit(1)

            if self.do_stats.get():
                extra["steps"].insert(extra["steps"].index('DumpCFG'), 'MSTGStats')
                extra["MSTGStats"] = {"dump": True, "log_level": "info"}

            extra["DumpCFG"]["dot"] = str(self.testname.get()) + ".dom" + str(HyperSSE.runid)
            extra["DumpInstances"]["dot"] = str(self.testname.get()) + ".dom" + str(HyperSSE.runid)
            extra["MultiSSE"]["file_name"] = str(self.testname.get()) + ".dom" + str(HyperSSE.runid)
            extra["HyperSSE"]["guests"] = ';'.join(guests)

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
            XEN.system_types.append(graph.os)
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

        if self.do_stats.get():
            self._step_manager.chain_step({"name": "MSTGStats", "dump": True, "log_level": "info"}, after="MultiSSE")

        log.warning("Done with single MultiSSEs, starting HyperSSE MultiSSE now!")
        HyperSSE.done = True
