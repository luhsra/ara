"""Container for OilStep."""
import graph
import json

from functools import partial

from native_step import Step


class OilStep(Step):
    """Reads an oil file and writes all information to the graph."""

    @staticmethod
    def fill_graph(g, oil, inst, inst_class, attrs=None):
        for elem in oil.get(inst, []):
            vertex = inst_class(g, elem['name'])
            if attrs is not None:
                for attr in attrs:
                    attrs[attr](elem[attr])
            g.set_vertex(vertex)

    def run(self, g: graph.PyGraph):
        print("Run ", self.get_name())

        # load the json outputstructure with json
        with open(self._config['oil']) as f:
            oil = json.load(f)

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
        fill_graph('resources', graph.Resource)
        fill_graph('alarms', graph.Alarm)
