#!/usr/bin/env python3
import os
import sys
sys.path.insert(0, '/home/bjoern/git/versuchung/src/')
import argparse
import matplotlib.pyplot as plt
from collections import defaultdict

from versuchung.experiment import Experiment
from versuchung.tex import DatarefDict
from versuchung.types import String, List

sys.path.append(os.path.dirname(__file__))


class CreateGraphsExp(Experiment):
    inputs = {
        # 'exp': analyze.GPSLoggerExp(default_experiment_instance="GPSLoggerExp-4f3345839082463c184be5b95d6a0585"),
        "results" :  lambda self:DatarefDict(filename=f"timing_result-{self.title}.dref"),
        "raw" : lambda self: DatarefDict(filename=f"timing_result_raw-{self.title}.dref"),
        "profiles": List(String)
        }

    def make_plot(self, marker, rows):
        label = marker.replace('_', ' ')
        x_values = list(rows.keys())
        y_values = [float(x) for x in rows.values()]
        result = plt.plot(x_values, y_values, label=label, marker='o')[0]
        plt.xticks(rotation=90)
        return result

    def new_dataset(self):
        # Plotting is done in order of insertion:
        data = {}
        for profile in self.inputs.profiles:
            data[str(profile)] = None

        return data
        for key in ['passthrough', 'vanilla', 'instances_full_static',
                    'instances_full_initialized']:
            data[key] = None

            # data[key + '.lto'] = None
        return data


    def run(self):
        data = defaultdict(self.new_dataset)
        # exit(1)
        for key, val in self.inputs.results.value.items():
            profile, marker = key.split('/')
            data[marker][profile] = val
        fig = plt.figure(21)
        axes = plt.subplot(211)
        # axes = plt.subplot(111)
        lines = []
        annot = axes.annotate("fdfdf", xy=(0,0), xytext=(-20,20), textcoords="offset points",
                            bbox=dict(boxstyle="round", fc="w"),
                            arrowprops=dict(arrowstyle='->'))
        annot.set_visible(False)


        def on_hover(event):
            is_visible = annot.get_visible()
            if event.inaxes == axes:
                match = [line for line in lines if line.contains(event)[0]]
                if match:
                    annot.set_text(" | ".join([m.get_label() for m in match]))
                    annot.xy = (event.xdata, event.ydata)
                    annot.set_visible(True)
                    fig.canvas.draw_idle()
                elif is_visible:
                    annot.set_visible(False)
                    fig.canvas.draw_idle()

        fig.canvas.mpl_connect("motion_notify_event", on_hover)

        # self.used_keys = []
        for marker, rows in data.items():
            if 'stdev' in marker:
                continue
            if marker == 'n':
                plt.annotate(f'n={rows["vanilla-none"]}', (.50, .90), xycoords='axes fraction')
                continue
            if 'size' in marker:
                continue
            lines.append(self.make_plot(marker, rows))
        plt.ylabel("time [cycles from reset]\n until reaching the marker")
        plt.legend(loc=7, bbox_to_anchor=(1.3, .5))
        plt.subplots_adjust(right=.75)
        plt.grid(True)

        plt.subplot(212)
        for marker, rows in data.items():
            if 'stdev' in marker:
                continue
            if marker == 'n':
                plt.annotate(f'n={rows["vanilla-none"]}', (.50, .90), xycoords='axes fraction')
                continue
            if 'size' not in marker:
                continue
            self.make_plot(marker, rows)
        plt.ylabel("size in bytes")
        plt.legend()
        plt.grid(True)

        plt.suptitle(f"{self.title} Startup Time and Memory Usage")
        plt.show()








if __name__ == "__main__":
    build_root = os.environ.get("MESON_BUILD_ROOT", None)
    if build_root:
        meson_subdir = os.environ.get("MESON_SUBDIR", None)
        build_dir = os.path.join(build_root, meson_subdir)
        os.chdir(build_dir)


    parser = argparse.ArgumentParser()
    parser.add_argument('--title', help='Directory from where to run ninja commands')
    args, unknown = parser.parse_known_args()

    experiment = CreateGraphsExp(title=args.title)
    dirname = experiment(unknown)
