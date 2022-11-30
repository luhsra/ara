"""Container for OilStep."""
from .option import Option, String
from .step import Step
import ara.os.autosar as _autosar

import json
import functools
import pyllco

from itertools import chain


class LoadOIL(Step):
    """Reads an oil file and writes all information to the graph.

    Expect the path to the oil file to be in the config 'oilfile' key.
    The syntax is changed to JSON. Take a look at tests/oil/1.oil.
    """

    oilfile = Option(name="oilfile", help="Path to JSON oil file.", ty=String())

    def get_single_dependencies(self):
        return ["LLVMMap", "SVFAnalyses"]

    def _fake_task_groups(self, tasks):
        for t_name, task in tasks.items():
            yield (t_name + "Group",
                   {"promises": [],
                    "tasks": {t_name: task}})

    def _add_edge(self, instances, src, tgt):
        e = instances.add_edge(src, tgt)
        instances.ep.quantity[e] = 1
        return e

    def run(self):
        cfg = self._graph.cfg

        from ara.steps import get_native_component

        ValueAnalyzer = get_native_component("ValueAnalyzer")
        va = ValueAnalyzer(self._graph)

        # load the json file
        oilfile = self.oilfile.get()
        if not oilfile:
            self._fail("No oilfile provided")
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
            self._fail("Couldn't find instance with name " + name)

        spinlock2vertex = {}
        for spinlocks in oil.get("spinlocks", []):
            old_spinlock = None
            for spinlock in spinlocks:
                if spinlock not in spinlock2vertex:
                    s = instances.add_vertex()
                    instances.vp.obj[s] = _autosar.Spinlock(
                        name=spinlock
                    )
                    instances.vp.label[s] = spinlock

                    code_instance = va.find_global(_autosar.SPINLOCK_PREFIX + spinlock)
                    if code_instance is not None:
                        va.assign_system_object(code_instance, instances.vp.obj[s])
                    spinlock2vertex[spinlock] = s
                else:
                    s = spinlock2vertex[spinlock]

                if old_spinlock:
                    e = self._add_edge(instances, old_spinlock, s)
                    instances.ep.label[e] = "nestable in order"
                    instances.ep.type[e] = _autosar.InstanceEdge.nestable
                old_spinlock = s

        res_scheduler = None
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
                )
                if "secondspertick" in counter:
                    instances.vp.obj[c].secondspertick = counter["secondspertick"]
                instances.vp.label[c] = c_name

            # events
            for e_name in cpu["events"].keys():
                code_instance = va.find_global(e_name)
                if code_instance is not None:
                    assert isinstance(code_instance, pyllco.GlobalVariable) and code_instance.is_constant()
                    constant = code_instance.get_initializer()
                    index = constant.get()
                else:
                    self._log.warn(f"Could not found Event {e_name} in the "
                                   "code. If the Event is used via symbol "
                                   " within a syscall, this will fail in "
                                   "later steps.")
                    index = None

                c = instances.add_vertex()
                instances.vp.obj[c] = _autosar.Event(name=e_name,
                                                     cpu_id=cpu_id,
                                                     index=index)
                instances.vp.label[c] = e_name

            # resources
            res_sched_name = []
            if cpu.get("os", {}).get("OsUseResScheduler", False):
                if res_scheduler is not None:
                    self._fail("RES_SCHEDULER must be activated on one core at maximum.")
                res_scheduler = cpu_id
                res_sched_name.append("RES_SCHEDULER")

            for r_name in chain(cpu["resources"].keys(), res_sched_name):
                r = instances.add_vertex()
                instances.vp.obj[r] = _autosar.Resource(name=r_name, cpu_id=cpu_id)
                instances.vp.label[r] = r_name

                code_instance = va.find_global(_autosar.RESOURCE_PREFIX + r_name)
                if code_instance is not None:
                    va.assign_system_object(code_instance, instances.vp.obj[r])

        for cpu in oil["cpus"]:
            cpu_id = cpu["id"]

            for tg_name, task_group in chain(cpu.get("task_groups", {}).items(), self._fake_task_groups(cpu.get("tasks", {}))):
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
                    self._log.debug(f"Found Task {t_name}")
                    instances.vp.obj[t] = _autosar.Task(
                        cfg=cfg,
                        name=t_name,
                        function=t_func,
                        priority=task["priority"],
                        activation=task["activation"],
                        autostart=task["autostart"],
                        schedule=task["schedule"],
                        accessing_application=task.get("accessing_application"),
                        cpu_id=cpu_id,
                        artificial=False
                    )
                    instances.vp.is_control[t] = True
                    instances.vp.label[t] = t_name

                    # link to TaskGroup
                    e = self._add_edge(instances, tg, t)
                    instances.ep.label[e] = "contains"
                    instances.ep.type[e] = _autosar.InstanceEdge.have

                    # link to events
                    for e_name in task.get("events", []):
                        event = find_instance_by_name(e_name, _autosar.Event)
                        e = self._add_edge(instances, t, event)
                        instances.ep.label[e] = "has"
                        instances.ep.type[e] = _autosar.InstanceEdge.have

                    # link to resources
                    r_sched_name = []
                    if res_scheduler == cpu_id:
                        r_sched_name.append("RES_SCHEDULER")

                    for r_name in chain(task.get("resources", []), r_sched_name):
                        resource = find_instance_by_name(r_name, _autosar.Resource)
                        e = self._add_edge(instances, t, resource)
                        instances.ep.label[e] = "use"
                        instances.ep.type[e] = _autosar.InstanceEdge.have

                    # link to spinlock
                    for s_name in task.get("spinlocks", []):
                        spinlock = find_instance_by_name(s_name, _autosar.Spinlock)
                        e = self._add_edge(instances, t, spinlock)
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

                obj = _autosar.Alarm(name=a_name, cpu_id=cpu_id)
                if "autostart" in alarm:
                    obj.autostart = alarm["autostart"]
                if "cycletime" in alarm:
                    obj.cycletime = alarm["cycletime"]
                if "alarmtime" in alarm:
                    obj.alarmtime = alarm["alarmtime"]
                instances.vp.obj[a] = obj
                instances.vp.label[a] = a_name

                # link to Counter
                c_v = find_instance_by_name(alarm["counter"], _autosar.Counter)
                e = self._add_edge(instances, c_v, a)
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
                    e = self._add_edge(instances, a, task)
                    instances.ep.label[e] = "activate"
                    instances.ep.type[e] = _autosar.InstanceEdge.activate
                elif action["action"].lower() == "setevent":
                    event = find_instance_by_name(action["event"], _autosar.Event)
                    e = self._add_edge(instances, a, event)
                    instances.ep.label[e] = "set"
                    instances.ep.type[e] = _autosar.InstanceEdge.activate
                else:
                    raise NotImplementedError

            # read all ISRs
            for i_name, isr in cpu.get("isrs", {}).items():
                i = instances.add_vertex()

                i_function_name = "AUTOSAR_ISR_" + i_name
                i_function = cfg.get_function_by_name(i_function_name)

                self._log.debug(f"Found ISR {i_name}")

                instances.vp.obj[i] = _autosar.ISR(
                        cfg=cfg,
                        name=i_name,
                        cpu_id=cpu_id,
                        function=i_function,
                        priority=isr["priority"],
                        category=isr["category"],
                        artificial=False
                )
                instances.vp.is_control[i] = True
                instances.vp.label[i] = i_name

                # trigger other steps
                self._step_manager.chain_step({"name": "Syscall",
                                               "entry_point": i_function_name})

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
