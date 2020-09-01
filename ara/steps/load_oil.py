"""Container for OilStep."""
import json

import ara.graph as _graph
from .option import Option, String
from .step import Step
from .autosar import Task, Counter, Alarm, AlarmAction

import graph_tool



class LoadOIL(Step):
    """Reads an oil file and writes all information to the graph.

    Expect the path to the oil file to be in the config 'oilfile' key.
    The syntax is changed to JSON. Take a look at tests/oil/1.oil.
    """
    def _fill_options(self):
        self.oilfile = Option(name="oilfile",
                              help="Path to JSON oil file.",
                              step_name=self.get_name(),
                              ty=String())
        self.opts.append(self.oilfile)

    def get_dependencies(self):
        return []

    def run(self, g: _graph.Graph):
        # load the json file
        oilfile = self.oilfile.get()
        if not oilfile:
            self.fail("No oilfile provided")
        self._log.info(f"Reading oil file {oilfile}")
        with open(oilfile) as f:
            oil = json.load(f)

        instances = graph_tool.Graph()
        g.os.init(instances)
        for cpu in oil["cpus"]:
            cpu_id = cpu["id"]

            # read all tasks
            for task in cpu["tasks"]:
                t = instances.add_vertex()
                t_name = task["name"]
                t_func_name = "AUTOSAR_TASK_FUNC_" + t_name
                t_func = g.cfg.get_function_by_name(t_func_name)
                instances.vp.obj[t] = Task(g.cfg, t_name, t_func,
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
        
        def find_instance_by_name(name, _class):
            obj = None
            for v in instances.vertices():
                obj = instances.vp.obj[v]
                if isinstance(obj, _class):
                    if obj.name == name:
                        return obj

            self.fail("Couldn't find instance with name " + name)

        for cpu in oil["cpus"]:
            cpu_id = cpu["id"]

            # read all counters
            for counter in cpu["counters"]:
                c = instances.add_vertex()
                instances.vp.obj[c] = Counter(counter["name"],
                                              cpu_id,
                                              counter["mincycle"],
                                              counter["maxallowedvalue"],
                                              counter["ticksperbase"],
                                              counter["secondspertick"])
                instances.vp.label[c] = counter["name"]

            # read all alarms
            for alarm in cpu["alarms"]:
                a = instances.add_vertex()
                instances.vp.label[a] = alarm["name"]

                # find counter object in instances
                c_name = alarm["counter"]
                counter = find_instance_by_name(c_name, Counter)

                # read alarm action
                action = alarm["action"]
                if action["action"].lower() == "incrementcounter":
                    incrementcounter = find_instance_by_name(action["counter"], Counter)
                    instances.vp.obj[a] = Alarm(alarm["name"],
                                                cpu_id,
                                                counter,
                                                alarm["autostart"],
                                                AlarmAction.INCREMENTCOUNTER,
                                                incrementcounter=incrementcounter)
                elif action["action"].lower() == "activatetask":
                    task = find_instance_by_name(action["task"], Task)
                    instances.vp.obj[a] = Alarm(alarm["name"],
                                                cpu_id,
                                                counter,
                                                alarm["autostart"],
                                                AlarmAction.ACTIVATETASK,
                                                task=task)
                elif action["action"].lower() == "setevent":
                    task = find_instance_by_name(action["task"], Task)
                    event = find_instance_by_name(action["event"], Event)
                    instances.vp.obj[a] = Alarm(alarm["name"],
                                                cpu_id,
                                                counter,
                                                alarm["autostart"],
                                                AlarmAction.SETEVENT,
                                                task=task,
                                                event=event)

                # set cycletime and alarmtime if autostart is true
                if instances.vp.obj[a].autostart:
                    instances.vp.obj[a].cycletime = alarm["cycletime"]
                    instances.vp.obj[a].alarmtime = alarm["alarmtime"]

        g.instances = instances

        if self.dump.get():
            uuid = self._step_manager.get_execution_id()
            dot_file = f'{uuid}.dot'
            dot_file = self.dump_prefix.get() + dot_file
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": 'Instances',
                                           "subgraph": 'instances'})
