#!/usr/bin/env python3
import argparse
import sys
import os
import statistics
import subprocess
import time
from multiprocessing import Process
from collections import defaultdict
import serial

from versuchung.experiment import Experiment
from versuchung.types import String, List, Integer
from versuchung.files import Directory
from versuchung.tex import DatarefDict


section_map= {
    '.text': ['flash text', 'flash sum'],
    '.initcallmodule.init': ['flash text', 'flash sum'],
    '.initcallsettings.init': ['flash text', 'flash sum'],
    '.init_array': ['flash text', 'flash sum'],
    '.ARM.exidx': ['flash text', 'flash sum'],
    '.ARM': ['flash text', 'flash sum'],
    '.irq_stack': ['ram bss', 'ram sum',],
    '.data': ['ram data', 'flash data', 'flash sum', 'ram sum',],
    '_uavo_handles': ['ram data', 'flash data', 'flash sum', 'ram sum',],
    '.bss': ['ram bss', 'ram sum',],
    '.heap': ['ram bss', 'ram sum',],
    '.boardinfo': ['flash text', 'flash sum'],
    '.isr_vector': ['flash text', 'flash sum'],
    '.rodata': ['flash text', 'flash sum'],
    '.sparse.spec': ['flash sparse', 'flash sum'],
    '.sparse.data': ['ram sparse', 'ram sum',],
    '.sparse.compressed.rle2': ['flash sparse', 'flash sum'],
    '.sparse.plain.rle': ['ram sparse', 'ram sum',],
    '._user_heap_stack': ['ram bss', 'ram sum',],
}


class GenericTimingExperiment(Experiment):
    inputs = {"result_dir": Directory(default_filename='gpslogger_results'),
              "serial_device": String("/dev/ttyACM0"),
              "reset_count": Integer(30),
              "profiles": List(String, default_value=[String("vanilla"),
                                                      String("instances_full_static"),
                                                      String("instances_full_initialized"),
                                                      String("passthrough"),
                                                      String("vanilla.lto"),
                                                      String("instances_full_static.lto"),
                                                      String("instances_full_initialized.lto"),
                                                      String("passthrough.lto"),
              ])}
    outputs = {"results": DatarefDict(filename=f"timing_result-.dref"),
               "raw": DatarefDict(filename=f"timing_result_raw-.dref")}

    def __init__(self, *args, run_dir=None, title=None, **kwargs):
        Experiment.__init__(self, *args, **kwargs)
        self.run_dir = run_dir or '..'
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

    def flash(self, profile):
        print("flashing ", profile)
        subprocess.run(["ninja", f"flash_{self.title}-{profile}"], cwd=self.run_dir, check=True)
        with serial.Serial(self.inputs.serial_device.value, 115200 * 8) as ser:
            # empty the serial buffer
            ser.read()

    @staticmethod
    def trigger_reset():
        subprocess.run(["st-info", "--chipid"], check=True,
                       stdout=subprocess.DEVNULL)

    @staticmethod
    def resetting(number):
        for i in range(number):
            print(f"Resetting: {i}")
            GenericTimingExperiment.trigger_reset()
            time.sleep(0.1)

    @staticmethod
    def count_successful_blocks(content):
        # Skip those blocks printed before system-setup point is reached
        end_markers = content.count(b"$$$")
        if b'done_taskCreate' in content:
            return end_markers - content.count(b'done_taskCreate: 0')
        return end_markers

    def get_time(self, profile):
        reset_count = self.inputs.reset_count.value
        p = Process(target=GenericTimingExperiment.resetting, args=(reset_count+10,))
        p.start()
        with serial.Serial(self.inputs.serial_device.value, 115200 * 8,
                           timeout=0.3*reset_count) as ser:
            content = b""
            while self.count_successful_blocks(content) < reset_count:
                content += ser.read(10)
        p.join()
        blocks = content.decode('utf-8').split('###\r\n')

        # Skip those blocks printed before system-setup point is reached
        if b'done_taskCreate' in content:
            blocks = [b for b in blocks if 'done_taskCreate: 0' not in b]
        else:
            print("WARNING: can't check for validity as there is no 'done_taskCreate' marker")


        times = defaultdict(list)

        if len(blocks) < reset_count+1:
            raise RuntimeError("Hardware behaves strange, block barriers not found")
        for idx in range(1, reset_count+1):
            block = blocks[idx]
            body = block.split("$$$")[0]
            for line in body.replace('\r', '\n').strip('\n').split('\n'):
                if not ':' in line:
                    if not len(line):
                        continue
                    print("line skipped:", line)
                    continue
                key, val = line.split(':')
                try:
                    val = int(val)
                except Exception as e:
                    print("line failed: ", line, e)
                    continue
                times[key].append(val)
                self.outputs.raw[f"{profile}/{idx}/{key}"] = val
        for key, val in times.items():
            self.outputs.results[f"{profile}/{key}"] = statistics.mean(val)
            self.outputs.results[f"{profile}/{key} stdev"] = statistics.stdev(val)
        self.outputs.results[f"{profile}/n"] = reset_count


    def run(self):
        print(self.inputs.profiles)
        for profile in self.inputs.profiles:
            print("starting profile ", profile)
            for k,v in self.get_size(profile).items():
                self.outputs.results[f"{profile}/size {k}"] = v

            self.flash(profile)
            try:
                self.get_time(profile)
            except:
                # try again
                print(f"Retry {profile}")
                self.get_time(profile)

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
