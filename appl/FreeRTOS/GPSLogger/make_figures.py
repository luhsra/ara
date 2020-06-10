#!/usr/bin/env python3
import os
import sys
import matplotlib.pyplot as plt
from collections import OrderedDict, defaultdict

from versuchung.experiment import Experiment
from versuchung.tex import DatarefDict

sys.path.append(os.path.dirname(__file__))
import analyze


class CreateGraphsExp(Experiment):
    inputs = {
        # 'exp': analyze.GPSLoggerExp(default_experiment_instance="GPSLoggerExp-4f3345839082463c184be5b95d6a0585"),
        "results" :  DatarefDict(filename="gpslogger_result.dref"),
        "raw" : DatarefDict(filename="gpslogger_raw.dref"),
        }

    def make_plot(self, marker, rows):
        label = marker.replace('_', ' ')
        plt.plot(list(rows.keys()), [float(x) for x in rows.values()], label=label)

    def new_dataset(self):
        # Plotting is done in order of insertion:
        data = {}
        for key in ['passthrough', 'vanilla', 'instances_full_static',
                    'instances_full_initialized']:
            data[key] = None
            data[key + '.lto'] = None
        return data


    def run(self):
        data = defaultdict(self.new_dataset)
        for key, val in self.inputs.results.value.items():
            profile, marker = key.split('/')
            data[marker][profile] = val
        plt.figure(21)
        plt.subplot(211)
        # self.used_keys = []
        for marker, rows in data.items():
            if 'stdev' in marker:
                continue
            if marker == 'n':
                plt.annotate(f'n={rows["vanilla"]}', (.50, .90), xycoords='axes fraction')
                continue
            if 'size' in marker:
                continue
            self.make_plot(marker, rows)
        plt.ylabel("time [cycles from reset]\n until reaching the marker")
        plt.legend()
        plt.grid(True)

        plt.subplot(212)
        for marker, rows in data.items():
            if 'stdev' in marker:
                continue
            if marker == 'n':
                plt.annotate(f'n={rows["vanilla"]}', (.50, .90), xycoords='axes fraction')
                continue
            if 'size' not in marker:
                continue
            self.make_plot(marker, rows)
        plt.ylabel("size in bytes")
        plt.legend()
        plt.grid(True)

        plt.suptitle("GPSLogger Startup Time and Memory Usage")
        plt.show()







if __name__ == "__main__":
    import sys

    experiment = CreateGraphsExp()
    dirname = experiment(sys.argv)
