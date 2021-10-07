"""Container for OilStep."""
from .option import Option, String
from .step import Step
import ara.os.autosar as _autosar

import json
import functools
import pyllco


class LoadOIL(Step):
    """Reads an oil file and writes all information to the graph.

    Expect the path to the oil file to be in the config 'oilfile' key.
    The syntax is changed to JSON. Take a look at tests/oil/1.oil.
    """

    oilfile = Option(name="oilfile", help="Path to JSON oil file.", ty=String())

    def get_single_dependencies(self):
        return ["LLVMMap", "SVFAnalyses"]

    def run(self):
        cfg = self._graph.cfg

        from ara.steps import get_native_component

        ValueAnalyzer = get_native_component("ValueAnalyzer")
        va = ValueAnalyzer(self._graph)

        # load the json file
        oilfile = self.oilfile.get()
        if not oilfile:
            self.fail("No oilfile provided")
        self._log.info(f"Reading oil file {oilfile}")
        with open(oilfile) as f:
            oil = json.load(f)

        # RegisterTaskEntry needs the ABBs of all Tasks (they will be created
        # as dependency of the Syscall step), so put it at the end by
        # requesting it first
        self._step_manager.chain_step({"name": "RegisterTaskEntry"})

        instances = self._graph.instances

        @functools.lru_cache(maxsize=8)
        def find_instance_by_name(name, _class):
            for v in instances.vertices():
                obj = instances.vp.obj[v]
                if isinstance(obj, _class):
                    if obj.name == name:
                        return v
            self.fail("Couldn't find instance with name " + name)

        for cpu in oil["cpus"]:
            cpu_id = cpu["id"]

            # counter
            for c_name, counter in cpu["counters"].items():
                c = instances.add_vertex()
                instances.vp.obj[c] = _autosar.Counter(
                    name=c_name,
                    cpu_id=cpu_id,
                    mincycle=counter["mincycle"],
                    maxallowedvalue=counter["maxallowedvalue"],
                    ticksperbase=counter["ticksperbase"],
                    secondspertick=counter["secondspertick"],
                )
                instances.vp.label[c] = c_name

            # events
            for e_name in cpu["events"].keys():
                code_instance = va.find_global(e_name)
                assert isinstance(code_instance, pyllco.GlobalVariable) and code_instance.is_constant()
                constant = code_instance.get_initializer()
                index = constant.get()

                c = instances.add_vertex()
                instances.vp.obj[c] = _autosar.Event(name=e_name,
                                                     cpu_id=cpu_id,
                                                     index=index)
                instances.vp.label[c] = e_name

            # resources
            for r_name in cpu["resources"].keys():
                r = instances.add_vertex()
                instances.vp.obj[r] = _autosar.Resource(name=r_name, cpu_id=cpu_id)
                instances.vp.label[r] = r_name

                code_instance = va.find_global(_autosar.RESOURCE_PREFIX + r_name)
                if code_instance is not None:
                    va.assign_system_object(code_instance, instances.vp.obj[r])

        for cpu in oil["cpus"]:
            cpu_id = cpu["id"]

            for tg_name, task_group in cpu["task_groups"].items():
                tg = instances.add_vertex()
                self._log.debug(f"Found TaskGroup {tg_name}")
                instances.vp.obj[tg] = _autosar.TaskGroup(
                    name=tg_name, cpu_id=cpu_id, promises=task_group["promises"]
                )
                instances.vp.label[tg] = tg_name

                # read all tasks
                for t_name, task in task_group["tasks"].items():
                    t = instances.add_vertex()
                    t_func_name = "AUTOSAR_TASK_FUNC_" + t_name
                    t_func = cfg.get_function_by_name(t_func_name)
                    # Use a fake ABB, since we don't have real ones yet.
                    # Leave this to the RegisterTaskEntry step
                    self._log.debug(f"Found Task {t_name}")
                    instances.vp.obj[t] = _autosar.Task(
                        cfg=cfg,
                        name=t_name,
                        function=t_func,
                        priority=task["priority"],
                        activation=task["activation"],
                        autostart=task["autostart"],
                        schedule=task["schedule"],
                        cpu_id=cpu_id,
                    )
                    instances.vp.is_control[t] = True
                    instances.vp.label[t] = t_name

                    # link to TaskGroup
                    e = instances.add_edge(tg, t)
                    instances.ep.label[e] = "contains"
                    instances.ep.type[e] = _autosar.InstanceEdge.have

                    # link to events
                    if "events" in task:
                        for e_name in task["events"]:
                            event = find_instance_by_name(e_name, _autosar.Event)
                            e = instances.add_edge(t, event)
                            instances.ep.label[e] = "has"
                            instances.ep.type[e] = _autosar.InstanceEdge.have

                    # link to resources
                    if "resources" in task:
                        for r_name in task["resources"]:
                            resource = find_instance_by_name(r_name, _autosar.Resource)
                            e = instances.add_edge(t, resource)
                            instances.ep.label[e] = "use"
                            instances.ep.type[e] = _autosar.InstanceEdge.have

                    # assign object to the concrete code
                    code_instance = va.find_global(_autosar.TASK_PREFIX + t_name)
                    if code_instance is not None:
                        va.assign_system_object(code_instance, instances.vp.obj[t])
                    else:
                        self._log.warning(f"Could not find task {t_name} in "
                                          "the code. This is likely to fail "
                                          "in later steps.")

                    # trigger other steps
                    self._step_manager.chain_step(
                        {"name": "Syscall", "entry_point": t_func_name}
                    )

        for cpu in oil["cpus"]:
            cpu_id = cpu["id"]

            for a_name, alarm in cpu["alarms"].items():
                a = instances.add_vertex()
                instances.vp.obj[a] = _autosar.Alarm(name=a_name, cpu_id=cpu_id)
                instances.vp.label[a] = a_name

                # link to Counter
                c_v = find_instance_by_name(alarm["counter"], _autosar.Counter)
                e = instances.add_edge(c_v, a)
                instances.ep.label[e] = "trigger"
                instances.ep.type[e] = _autosar.InstanceEdge.trigger

                # assign object to the concrete code
                code_instance = va.find_global(_autosar.ALARM_PREFIX + a_name)
                if code_instance is not None:
                    va.assign_system_object(code_instance, instances.vp.obj[a])

                # read alarm action
                action = alarm["action"]
                if action["action"].lower() == "incrementcounter":
                    raise NotImplementedError
                    # incrcounter = find_instance_by_name(action["counter"],
                    #                                     Counter)
                    # instances.vp.obj[a] = Alarm(alarm["name"],
                    #                             cpu_id,
                    #                             counter,
                    #                             alarm["autostart"],
                    #                             AlarmAction.INCREMENTCOUNTER,
                    #                             incrementcounter=incrcounter)
                elif action["action"].lower() == "activatetask":
                    task = find_instance_by_name(action["task"], _autosar.Task)
                    e = instances.add_edge(a, task)
                    instances.ep.label[e] = "activate"
                    instances.ep.type[e] = _autosar.InstanceEdge.activate
                elif action["action"].lower() == "setevent":
                    raise NotImplementedError
                    # task = find_instance_by_name(action["task"], Task)
                    # event = find_instance_by_name(action["event"], Event)
                    # instances.vp.obj[a] = Alarm(alarm["name"],
                    #                             cpu_id,
                    #                             counter,
                    #                             alarm["autostart"],
                    #                             AlarmAction.SETEVENT,
                    #                             task=task,
                    #                             event=event)

                # set cycletime and alarmtime if autostart is true
                # if instances.vp.obj[a].autostart:
                #     instances.vp.obj[a].cycletime = alarm["cycletime"]
                #     instances.vp.obj[a].alarmtime = alarm["alarmtime"]

            # read all ISRs
            # for isr in cpu["isrs"]:
            #     i = instances.add_vertex()
            #     instances.vp.label[i] = isr["name"]

            #     i_function_name = "AUTOSAR_ISR_" + isr["name"]
            #     i_function = g.cfg.get_function_by_name(i_function_name)

            #     group = []
            #     for name in isr["group"]:
            #         task = find_instance_by_name(name, Task)
            #         group.append(task)

            #     instances.vp.obj[i] = ISR(i_function_name,
            #                               cpu_id,
            #                               isr["category"],
            #                               isr["priority"],
            #                               i_function,
            #                               group)

            #     # trigger other steps
            #     self._step_manager.chain_step({"name": "Syscall",
            #                                     "entry_point": i_function_name})

        self._log.debug(
            "find_instance_by_name " f"{find_instance_by_name.cache_info()}"
        )

        if self.dump.get():
            self._step_manager.chain_step(
                {
                    "name": "Printer",
                    "dot": self.dump_prefix.get() + "instances.dot",
                    "graph_name": "Instances",
                    "subgraph": "instances",
                }
            )
