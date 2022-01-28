#!/usr/bin/env python3
import argparse
import sys
import os
import statistics
import subprocess
import time
from multiprocessing import Process
from collections import defaultdict
import json

from versuchung.experiment import Experiment
from versuchung.types import String, List, Integer
from versuchung.files import Directory
from versuchung.tex import DatarefDict
from versuchung.archives import GitArchive
from versuchung.execute import shell

import logging
logging.basicConfig(level=logging.DEBUG)


from os import path as osp
experiment_dir = osp.dirname(osp.abspath(__file__))


class GenericTimingExperiment(Experiment):
    inputs = {"ara": GitArchive(osp.join(experiment_dir, '../../../../')),
              "seed_offset": Integer(0),
              "result_dir": Directory(default_filename='gpslogger_results'),
              }
    outputs = {"results": DatarefDict(filename=f"multisse_result-.dref"),
               "raw": DatarefDict(filename=f"multisse_result_raw-.dref"),
               "dicts": Directory(experiment_dir, filename_filter="*.dict*"),
               }

    def __init__(self, *args, run_dir=None, title=None, **kwargs):
        Experiment.__init__(self, *args, **kwargs)
        self.run_dir = osp.abspath(run_dir or os.getcwd())
        if title:
            self.title = title

    def get_size(self, profile):
        print("retrieving size of ", profile)
        try:
            print(os.getcwd())
            result = subprocess.run(["ninja", f"size_{self.title}-{profile}"],
                                    check=True,
                                    cwd=self.run_dir,
                                    stderr=subprocess.PIPE,
                                    stdout=subprocess.PIPE)
            content = result.stdout.decode()
            result = defaultdict(lambda:0)
            print("content: ", content)
            for line in content.split('\n'):
                # print(line)
                if ':' in line:
                    continue
                if 'size' in line:
                    continue
                parts = line.split()
                if len(parts) != 3:
                    continue
                name, size, addr = parts
                if not addr or addr == '0':
                    continue
                for sec in section_map[name]:
                    result[sec] += int(size)
            return result
        except subprocess.CalledProcessError as e:
            print("cmd:", e.cmd)
            print("Ret:", e.returncode)
            print("out:", e.stdout.decode())
            print("err:", e.stderr.decode())
            raise e


    def run(self):
        RUNS = 1

        result = {"with_timing": [],
                  "no_timing": []}
        for run in range(RUNS):
            seed = self.seed_offset.value + run
            logging.info("Generating Benchmark, seed=%d", seed)
            cmd = "cd %s;./benchmark_gen.py --seed %s"
            shell(cmd, experiment_dir, str(seed))

            for timed in ['no']:#, 'with']:
                logging.info("Executing MultiSSE %s", timed)
                fname = "appl/AUTOSAR/multicore/dynamic/synthetic.multisse.%s_timing.stepdata.json"
                cmd = f"cd %s; ninja {fname}"
                start_time = time.time()
                shell(cmd, self.run_dir, timed)
                end_time = time.time()
                logging.info(os.getcwd())
                with open(osp.join(self.run_dir, fname % timed), 'r') as infile:
                    res = json.load(infile)
                    res['duration'] = end_time - start_time
                    res['seed'] = seed
                    res['timed'] = timed
                    result[timed+'_timing'].append(res)
                    stats = self.dicts.new_file("%s.%s.dict" % (seed, timed))
                    stats.value = json.dumps(res)

        result_file = self.dicts.new_file("sum.dict")
        result_file.value = json.dumps(result)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--run-dir', help='Directory from where to run ninja commands')
    parser.add_argument('--title', help='Directory from where to run ninja commands')
    args, unknown = parser.parse_known_args()
    experiment = GenericTimingExperiment(run_dir=args.run_dir, title=args.title)
    dirname = experiment(unknown)
    print(dirname)

    for out in experiment.outputs.items():
        real = out[1].path
        old_name = os.path.splitext(out[1].basename)
        new_name = f"{old_name[0]}{experiment.title}{old_name[1]}"
        link = os.path.join(os.path.dirname(out[1].path), '..', new_name)
        print(f'creating symlink at "{link}" pointing to "{real}"')
        try:
            os.unlink(link)
        except:
            pass
        os.symlink(real, link)


if __name__ == "__main__":
    main()
