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
logger = logging.getLogger(__name__)

try:
    pass
    import coloredlogs
    colors = coloredlogs.parse_encoded_styles("debug=green;info=green;warning=yellow,bold;error=red;critical=red,bold")
    fields = coloredlogs.parse_encoded_styles("name=blue;levelname=white,bold")
    coloredlogs.install(fmt="[%(name)s] %(levelname)s: %(message)s",
                        level='DEBUG',
                        level_styles=colors, field_styles=fields)
    logger.set_level(logging.DEBUG)
except:
    pass


from os import path as osp
experiment_dir = osp.dirname(osp.abspath(__file__))


INIT = """
ir_files = []
no_jsons = []
with_jsons = []
all_jsons = []
"""

GEN = """
{name}_cc = custom_target('{name}_cc',
  output: ['{cc_file}', '{oil_file}'],
  command: [benchmark_gen, '--seed', '{seed}', '--system', '@OUTPUT0@',
             '--oil', '@OUTPUT1@', '--cores', '{num_cores}', '--locks', '{num_locks}',
             '--lock-users', '{num_lock_users}', '--subtasks', '{num_subtasks}',
             '--at-local', '{perc_at_local}', '--se-local', '{perc_se_local}',
             '--events', '{num_events}']
  )
"""

COMPILE = """
{name}_ll = custom_target('{name}_ll',
  input: {name}_cc[0],
  depfile: '{cc_file}.dep',
  output: '{cc_file}.ll',
  command: clang_cpp + libs_includes + ir_flags + clang_flags)
ir_files += {name}_ll
"""

RUN_ARA = """
{name}_{timed}_stepdata = custom_target('{name}_{timed}_stepdata',
  input: [ara_py, {name}_ll],
  output: '{name}.multisse.{timed}_timing.stepdata.json',
  command: [py3_inst, ara_py, {name}_ll,
  '--oilfile', {name}_cc[1],
  '--step-settings', {timed}_timing_settings,
  '--timings', 'BB',
  '--os', 'AUTOSAR',
  '--step-data', '@OUTPUT0@'],
)

{timed}_jsons +={name}_{timed}_stepdata
all_jsons += {name}_{timed}_stepdata
"""

RUN_ARA_OUTFILE = """{name}.multisse.{timed}_timing.stepdata.json"""

DEPENDER = """
run_target('run_multisse_dynamic_experiment_all', command: ['ls'], depends: all_jsons)
run_target('run_multisse_dynamic_experiment_generator', command: ['echo', 'generator finished'], depends: ir_files)
run_target('run_multisse_dynamic_experiment_no_timing', command: ['ls'], depends: no_jsons)
run_target('run_multisse_dynamic_experiment_with_timing', command: ['ls'], depends: with_jsons)
"""

DEPENDER_GENERATOR = 'run_multisse_dynamic_experiment_generator'

DEPENDER_NAME = 'run_multisse_dynamic_experiment_all'


class GenericTimingExperiment(Experiment):
    inputs = {"ara": GitArchive(osp.join(experiment_dir, '../../../../')),
              "seed_offset": Integer(0),
              "result_dir": Directory(default_filename='gpslogger_results'),
              }
    outputs = {"results": DatarefDict(filename=f"multisse_result-.dref"),
               "raw": DatarefDict(filename=f"multisse_result_raw-.dref"),
               "dicts": Directory(experiment_dir, filename_filter="*.json*"),
               }

    def __init__(self, *args, run_dir=None, title=None, collect_only=False, **kwargs):
        Experiment.__init__(self, *args, **kwargs)
        self.run_dir = osp.abspath(run_dir or os.getcwd())
        self.ara_cmd = osp.join(self.run_dir, 'ara.py')
        self.collect_only = collect_only

        if title:
            self.title = title



    def run(self):
        RUNS = 100

        result = {"with_timing": [],
                  "no_timing": [],
                  "stepdata": {}}
        logger.info("Writing meson file")
        with open(osp.join(experiment_dir, 'gen', 'meson.build'), 'w') as mf:
            mf.write(INIT)
            for num_cores in [2, 3, 6]:
                for num_locks in [1, 3]:
                    for num_lock_users in [2, 6]:
                        for num_subtasks in [15]:
                            for perc_at_local in [90]:
                                for perc_se_local in [90]:
                                    for num_events in [0, 5]:
                                        for run in range(RUNS):
                                            res = self.gen_system(
                                                run=run,
                                                num_cores=num_cores,
                                                num_locks=num_locks,
                                                num_lock_users=num_lock_users,
                                                num_subtasks=num_subtasks,
                                                perc_at_local=perc_at_local,
                                                perc_se_local=perc_se_local,
                                                num_events=num_events,
                                                mf=mf,
                                            )
                                            result['stepdata'].update(res)
            mf.write(DEPENDER)
        logger.info("Generating Benchmarks")
        if not self.collect_only:
            shell(f"cd {self.run_dir}; ninja {DEPENDER_GENERATOR}")
        logger.info("Executing MultiSSE")
        if not self.collect_only:
            cmd = f"cd %s; ninja -k 0 %s"
            shell(cmd, self.run_dir, DEPENDER_NAME)
        res_details = self.collect_results(result)
        details_file = self.dicts.new_file("sum.details.json")
        details_file.value = json.dumps(res_details)
        res_summary = self.summarize_results(res_details)
        summary_file = self.dicts.new_file("sum.json")
        summary_file.value = json.dumps(res_summary)

    def summarize_results(self, details):
        res = {'no': {}, 'with': {}, 'count': {}, 'better': {}}

        for metric, data in details.items():
            with_timing = 0
            no_timing = 0
            count = 0
            for entry in data.values():
                if len(entry) != 2:
                    continue
                with_timing += entry['with']
                no_timing += entry['no']
                count += 1
            better = no_timing - with_timing
            res['with'][metric] = with_timing
            res['no'][metric] = no_timing
            res['better'][metric] = better
            res['count'][metric] = count
        return res

    def collect_results(self, result):
        buildpath = osp.join(self.run_dir, 'appl/AUTOSAR/multicore/dynamic/gen/')
        res = {'rounds': {},
               'vertices': {},
               'edges': {},
               'num_callsites':{},
               'spinning_callsites': {},
               'passing_callsites': {},
               'ipi_needed': {},
               'ipi_avoidable': {},
               'deadlocks': {},
               }
        for name, data in result['stepdata'].items():
            for k in res:
                res[k][name] = {}
            for timed, sfile in data.items():
                try:
                    with open(osp.join(buildpath, sfile), 'r') as f:
                        stats = json.load(f)
                except FileNotFoundError as e:
                    logger.warning("Not found, hence skipping: %s", sfile)
                    continue
                for k in ['rounds', 'edges', 'vertices']:
                    res[k][name][timed] = stats['MultiSSE'][k]
                num_callsites = 0
                spinning_callsites = 0
                passing_callsites = 0
                for v in stats['LockElision']['callsites'].values():
                    num_callsites += 1
                    spinning_callsites += int(v['spins'])
                    passing_callsites += int(not v['spins'])
                res['num_callsites'][name][timed] = num_callsites
                res['spinning_callsites'][name][timed] = spinning_callsites
                res['passing_callsites'][name][timed] = passing_callsites
                needed_ipis = 0
                avoidable_ipis = 0
                for v in stats['IPIAvoidance']:
                    avoidable_ipis += int(v['ipi_needed'])
                    needed_ipis += int(not v['ipi_needed'])
                res['ipi_needed'][name][timed] = needed_ipis
                res['ipi_avoidable'][name][timed] = avoidable_ipis
                res['deadlocks'][name][timed] = len(stats['LockElision']['DEADLOCK'])
        return res



    def gen_system(self, run, num_cores, num_locks, num_lock_users, num_subtasks,
                   perc_at_local, perc_se_local, num_events, mf):
        seed = self.seed_offset.value + run

        name = (f'synthetic_{num_cores:02}C_{num_locks:02}L_{num_lock_users}U'
                f'_{num_subtasks:02}T'
                f'_{perc_at_local:02}A_{perc_se_local:02}S_{num_events:02}E'
                f'__{seed:04}')
        cc_file = f'{name}.cc'
        oil_file = f'{name}.oil.json'
        cmd = (f'cd %s;./benchmark_gen.py --seed {seed} --system gen/{cc_file} '
               f'--oil gen/{oil_file} --cores {num_cores} --locks {num_locks} '
               f'--lock-users {num_lock_users} --subtasks {num_subtasks} '
               f'--at-local {perc_at_local} --se-local {perc_se_local} '
               f'--events {num_events}')
        # if not self.collect_only:
        #     shell(cmd, experiment_dir)
        mf.write(GEN.format(seed=seed, cc_file=cc_file, oil_file=oil_file,
                            num_cores=num_cores, num_locks=num_locks,
                            num_lock_users=num_lock_users,
                            num_subtasks=num_subtasks,
                            perc_at_local=perc_at_local,
                            perc_se_local=perc_se_local,
                            num_events=num_events,
                            name=name,
                            ))

        mf.write(COMPILE.format(name=name,
                                cc_file=cc_file))
        ret = {name: {}}
        for timed in ['no', 'with']:
            mf.write(RUN_ARA.format(name=name,
                                    timed=timed,
                                    oil_file=oil_file))
            ret[name][timed] = RUN_ARA_OUTFILE.format(name=name,
                                                      timed=timed,
                                                      oil_file=oil_file)
        return ret


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--run-dir', help='Directory from where to run ninja commands')
    parser.add_argument('--title', help='Directory from where to run ninja commands')
    parser.add_argument('--collect-only', action='store_true',
                        help='collect results without new generation')
    args, unknown = parser.parse_known_args()
    experiment = GenericTimingExperiment(run_dir=args.run_dir, title=args.title,
                                         collect_only=args.collect_only)
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
