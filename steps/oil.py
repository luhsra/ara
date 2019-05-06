"""Container for OilStep."""
import graph
import json

from functools import partial
from typing import Dict, Any

from native_step import Step


class OilStep(Step):
    """Reads an oil file and writes all information to the graph."""

    def fill_graph(self, g, oil: Dict[str, Any], inst, inst_class, attrs=None):
        """Create new graph instance.

        Arguments:
        g   -- graph
        oil -- oilfile
        inst -- key of the instance in the oilfile
        inst_class -- class of the instance in the graph

        Keyword arguments:
        attrs -- optional dict of attributes and setter functions
                 Used to set all instance attributes.
        """
        self._log.debug(f"Filling {inst}")
        for elem in oil.get(inst, []):
            self._log.debug(f"Found in oil: {elem}")
            vertex = inst_class(g, elem['name'])
            if attrs is not None:
                for attr in attrs:
                    attrs[attr](vertex, elem[attr])
            g.set_vertex(vertex)

    def run(self, g: graph.PyGraph):
        # load the json outputstructure with json
        with open(self._config['oilfile']) as f:
            oil = json.load(f)
        assert("cpu" in oil)
        oil = oil["cpu"]

        # TODO validate json

        counter_m = {'maxallowedvalue': graph.Counter.set_max_allowed_value,
                     'ticksperbase': graph.Counter.set_ticks_per_base,
                     'mincycle': graph.Counter.set_min_cycle}

        task_m = {'priority': graph.Task.set_priority,
                  'autostart': graph.Task.set_autostart,
                  'schedule': graph.Task.set_scheduler,
                  'activation': graph.Task.set_activation}

        fill_graph = partial(self.fill_graph, g, oil)

        fill_graph('isrs', graph.ISR)
        fill_graph('counters', graph.Counter, attrs=counter_m)
        fill_graph('events', graph.Event)
        fill_graph('tasks', graph.Task, attrs=task_m)
        fill_graph('resources', graph.Mutex)
        fill_graph('alarms', graph.Timer)
