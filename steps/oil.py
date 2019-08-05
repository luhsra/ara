"""Container for OilStep."""
import graph
import json

from functools import partial
from typing import Dict, Any

from .option import Option, String

from native_step import Step


class OilStep(Step):
    """Reads an oil file and writes all information to the graph.

    Expect the path to the oil file to be in the config 'oilfile' key.
    The syntax is changed to JSON. Take a look at tests/oil/1.oil.
    """

    @staticmethod
    def event_set_mask(vertex, value):
        """Helper function to translate event mask values."""
        if value == "auto":
            value = graph.Event.MASK_AUTO
        vertex.set_event_mask(value)

    @staticmethod
    def resource_type(vertex, value):
        """Helper function to check for resource types"""
        if value == "standard" or value == "internal":
            vertex.set_resource_property(value, "")
        else:
            raise NotImplementedError("Linked resource is not implemented.")

    @staticmethod
    def resource_init(vertex):
        """Set OSEK protocol type."""
        vertex.set_protocol_type(graph.protocol_type.priority_ceiling)
        vertex.set_handler_name("OSEKOS_RESOURCE_" + vertex.get_name())

    def link_function_to_instance(self, vertex, prefix):
        """For ISRs and tasks: Link function to instance and vice versa."""
        codename = prefix + vertex.get_name()
        func = self.functions[codename]

        if not vertex.set_definition_function(codename):
            raise Exception("Could not find reference for {vertex} in code")
        func.set_definition_vertex(vertex)

    def task_init(self, vertex):
        """Link OSEK task with code instance."""
        vertex.set_handler_name("OSEKOS_TASK_" + vertex.get_name())
        self.link_function_to_instance(vertex, "OSEKOS_TASK_FUNC_")

    def event_init(self, vertex):
        """Link OSEK event with code instance."""
        vertex.set_handler_name("OSEKOS_EVENT_" + vertex.get_name())

    def alarm_init(self, vertex):
        """Link OSEK alarm with code instance."""
        vertex.set_handler_name("OSEKOS_ALARM_" + vertex.get_name())

    def isr_init(self, vertex):
        """Link OSEK ISR with code instance."""
        vertex.set_handler_name("OSEKOS_ISR_" + vertex.get_name())
        self.link_function_to_instance(vertex, "OSEKOS_ISR_")

    @staticmethod
    def alarm_action(vertex, value):
        """Link OSEK alarm with task."""
        if value["type"] != "activatetask":
            raise NotImplementedError("Alarms: Other types than activatetask" +
                                      "are not implemented.")
        vertex.set_task_reference(value['task'])

    def fill_graph(self, g, oil: Dict[str, Any], inst, inst_class, attrs=None,
                   inits=None):
        """Create new graph instance.

        Arguments:
        g   -- graph
        oil -- oilfile
        inst -- key of the instance in the oilfile
        inst_class -- class of the instance in the graph

        Keyword arguments:
        attrs -- optional dict of attributes and setter functions
                 Used to set all instance attributes.
        inits -- optional list of functions that are called with the newly
                 created instance. Used for instance initialization.
        """
        self._log.debug(f"Filling {inst}")
        for elem in oil.get(inst, []):
            self._log.debug(f"Found in oil: {elem}")
            vertex = inst_class(g, elem['name'])
            if attrs is not None:
                for attr in attrs:
                    if attr in elem:
                        attrs[attr](vertex, elem[attr])
            if inits is not None:
                for init in inits:
                    init(vertex)
            g.set_vertex(vertex)

    def _fill_options(self):
        self.oilfile = Option(name="oilfile",
                              help="Path to JSON oil file.",
                              step_name=self.get_name(),
                              ty=String())
        self.opts.append(self.oilfile)

    def get_dependencies(self):
        return ['ABB_MergeStep']

    def run(self, g: graph.PyGraph):
        # load the json outputstructure with json
        oilfile, valid = self.oilfile.get()
        if not valid:
            self._log.error("No oilfile provided.")
            raise RuntimeError("No oilfile provided.")
        self._log.info(f"Reading oil file {oilfile}")
        with open(oilfile) as f:
            oil = json.load(f)
        assert("cpu" in oil)
        oil = oil["cpu"]

        # TODO validate json

        # prepare graph functions:
        funcs = g.get_type_vertices("Function")
        self.functions = dict([(x.get_name(), x) for x in funcs])

        counter_m = {'maxallowedvalue': graph.Counter.set_max_allowed_value,
                     'ticksperbase': graph.Counter.set_ticks_per_base,
                     'mincycle': graph.Counter.set_min_cycle}

        task_m = {'priority': graph.Task.set_priority,
                  'autostart': graph.Task.set_autostart,
                  'schedule': graph.Task.set_scheduler,
                  'activation': graph.Task.set_activation}
        event_m = {'mask': OilStep.event_set_mask}
        resources_m = {'type': OilStep.resource_type}
        alarm_m = {'action': OilStep.alarm_action}
        isr_m = {'category': graph.ISR.set_category,
                 'priority': graph.ISR.set_priority}

        fill_graph = partial(self.fill_graph, g, oil)

        # fill the graph, according to the OIL specification some dependencies
        # must be met:
        # FOO -> BAR: FOO depends on BAR
        # alarm -> counter
        # alarm -> task
        # ISR -> resource
        fill_graph('events', graph.Event, attrs=event_m,
                   inits=[self.event_init])
        fill_graph('counters', graph.Counter, attrs=counter_m)
        fill_graph('tasks', graph.Task, attrs=task_m,
                   inits=[self.task_init])
        fill_graph('alarms', graph.Timer, attrs=alarm_m,
                   inits=[self.alarm_init])
        fill_graph('resources', graph.Mutex, attrs=resources_m,
                   inits=[OilStep.resource_init])
        fill_graph('isrs', graph.ISR, attrs=isr_m,
                   inits=[self.isr_init])
