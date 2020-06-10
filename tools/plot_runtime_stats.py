#!/usr/bin/env python3
"""Plot multiple runtime statistics in an interactive plot."""

import argparse
import colorsys
import itertools
import json
import numpy as np
import math
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.colors as mc
import sys

from collections import namedtuple
from os.path import splitext, basename

Step = namedtuple("Step", ["name", "uuid", "runtime"])
Execution = namedtuple("Execution", ["name", "steps"])

PlotStep = namedtuple("PlotStep", ["base_color", "invocations", "max_time", "label"])
Invocation = namedtuple("Invocation", ["time"])
PlotData = namedtuple("PlotData", ["steps", "bar_labels", "y_pos"])


def p_print(obj):
    import pprint
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(obj)


def equidistribute(values, amount, default_value):
    class EquiIter:
        def __init__(self):
            self._values = iter(values)
            self._counter = 0
            self._step = amount/len(values)
            self._next_good_number = (self._step - 1) / 2

        def __next__(self):
            if self._counter == math.floor(self._next_good_number):
                self._next_good_number += self._step
                val = next(self._values)
            else:
                val = default_value
            self._counter += 1
            return val
    return EquiIter()


# see: https://stackoverflow.com/a/49601444
def adjust_lightness(color, amount=0.5):
    try:
        c = mc.cnames[color]
    except:
        c = color
    c = colorsys.rgb_to_hls(*mc.to_rgb(c))
    return colorsys.hls_to_rgb(c[0], max(0, min(1, amount * c[1])), c[2])


def prepare_data_for_plotting(stats):
    y_pos = np.arange(len(stats))
    bar_labels = [x.name for x in stats]

    temp_steps = {}

    for ex in stats:
        for step in ex.steps:
            if step.name not in temp_steps:
                temp_steps[step.name] = {}
            if ex.name not in temp_steps[step.name]:
                temp_steps[step.name][ex.name] = []
            temp_steps[step.name][ex.name].append(step)

    for step in temp_steps.values():
        for ex in step:
            invcs = step[ex]
            max_time = sum(x.runtime for x in invcs)
            step[ex] = (invcs, max_time)

    sorted_temp_steps = sorted(list(temp_steps.items()),
                               key=lambda x: max(y[1] for y in x[1].values()),
                               reverse=True)

    tab10 = cm.get_cmap('tab10')
    color_cycle = itertools.cycle(tab10.colors)

    steps = []
    for step in sorted_temp_steps:
        times = []
        for ex in step[1].values():
            times.append([s.runtime for s in ex[0]])
        max_len = max(len(x) for x in times)
        times_equi = [equidistribute(x, max_len, 0) for x in times]

        invcs = []
        for i in range(max_len):
            vals = [next(x) for x in times_equi]
            invcs.append(Invocation(time=np.array(vals)))
        max_times = np.array([x[1] for x in step[1].values()])
        steps.append(PlotStep(base_color=next(color_cycle), invocations=invcs,
                              max_time=max_times, label=step[0]))

    return PlotData(steps=steps, bar_labels=bar_labels, y_pos=y_pos)


def main():
    parser = argparse.ArgumentParser(description=sys.modules[__name__].__doc__)
    parser.add_argument('STAT_FILE', nargs='+',
                        help='statistic files, that are plotted')
    args = parser.parse_args()

    ex_counter = 0
    ex_names = set()

    stats = []
    for stat_file in args.STAT_FILE:
        steps = []
        ex_name = splitext(basename(stat_file))[0]
        if ex_name in ex_names:
            ex_name += str(ex_counter)
            ex_counter += 1
        ex_names.add(ex_name)

        with open(stat_file) as f:
            ex_stat = json.load(f)
            for step_name, s_uuid, runtime in ex_stat:
                steps.append(Step(name=step_name, uuid=s_uuid, runtime=runtime))
        stats.append(Execution(name=ex_name, steps=steps))

    plot_data = prepare_data_for_plotting(stats)

    plt.rcdefaults()
    fig, ax = plt.subplots()

    al_pr_times = np.empty(len(plot_data.y_pos))

    for step in plot_data.steps:
        grey_map = np.linspace(0.75, 1.25, len(step.invocations))
        label_pos = al_pr_times + (step.max_time) / 2
        for i, invc in enumerate(step.invocations):
            color = adjust_lightness(step.base_color, grey_map[i])
            ax.barh(plot_data.y_pos, invc.time, left=al_pr_times,
                    align='center', color=color)
            al_pr_times += invc.time
        for i, y in enumerate(plot_data.y_pos):
            ax.annotate(step.label,
                        (label_pos[i], y),
                        ha='center')

    ax.set_yticks(plot_data.y_pos)
    ax.set_yticklabels(plot_data.bar_labels)
    ax.invert_yaxis()  # labels read top-to-bottom
    ax.set_xlabel('Execution time')
    ax.set_title('Step execution times')

    plt.show()


if __name__ == '__main__':
    main()
