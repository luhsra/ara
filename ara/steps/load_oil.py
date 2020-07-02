"""Container for OilStep."""
import json

import ara.graph as _graph
from .option import Option, String
from .step import Step
from .autosar import Task

import graph_tool



class LoadOIL(Step):
    """Reads an oil file and writes all information to the graph.

    Expect the path to the oil file to be in the config 'oilfile' key.
    The syntax is changed to JSON. Take a look at tests/oil/1.oil.
    """
    oilfile = Option(name="oilfile",
                     help="Path to JSON oil file.",
                     ty=String())

    def run(self):
        # load the json file
        oilfile = self.oilfile.get()
        if not oilfile:
            self.fail("No oilfile provided")
        self._log.info(f"Reading oil file {oilfile}")
        with open(oilfile) as f:
            oil = json.load(f)

        instances = graph_tool.Graph()
        self._graph.os.init(instances)
        for cpu in oil["cpus"]:
            cpu_id = cpu["id"]
            for task in cpu["tasks"]:
                t = instances.add_vertex()
                t_name = task["name"]
                t_func_name = "AUTOSAR_TASK_FUNC_" + t_name
                t_func = self._graph.cfg.get_function_by_name(t_func_name)
                instances.vp.obj[t] = Task(self._graph.cfg, t_name, t_func,
                                           task["priority"],
                                           task["activation"],
                                           task["autostart"],
                                           task["schedule"],
                                           cpu_id)
                instances.vp.label[t] = t_name

                # trigger other steps
                self._step_manager.chain_step({"name": "ValueAnalysis",
                                               "entry_point": t_func_name})
                self._step_manager.chain_step({"name": "ValueAnalysisCore",
                                               "entry_point": t_func_name})
                self._step_manager.chain_step({"name": "CallGraph",
                                               "entry_point": t_func_name})
                self._step_manager.chain_step({"name": "Syscall",
                                               "entry_point": t_func_name})
                self._step_manager.chain_step({"name": "ICFG",
                                               "entry_point": t_func_name})

        self._graph.instances = instances

        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            dot_file = f'{uuid}.dot'
            dot_file = self.dump_prefix.get() + dot_file
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'Instances',
                                           "subgraph": 'instances'})
