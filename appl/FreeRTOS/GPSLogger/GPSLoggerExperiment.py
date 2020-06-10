#!/usr/bin/env python3
import argparse
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



class GPSLoggerExp(Experiment):
    inputs = {"result_dir": Directory(default_filename='gpslogger_results'),
              "serial_device": String("/dev/ttyACM0"),
              "reset_count": Integer(300),
              "profiles": List(String, default_value=[String("vanilla"),
                                                      String("instances_full_static"),
                                                      String("instances_full_initialized"),
                                                      String("passthrough"),
                                                      String("vanilla.lto"),
                                                      String("instances_full_static.lto"),
                                                      String("instances_full_initialized.lto"),
                                                      String("passthrough.lto"),
              ])}
    outputs = {"results": DatarefDict(filename="gpslogger_result.dref"),
               "raw": DatarefDict(filename="gpslogger_raw.dref")}

    def __init__(self, *args, run_dir=None, **kwargs):
        Experiment.__init__(self, *args, **kwargs)
        self.run_dir = run_dir or '..'

    def get_size(self, profile):
        print("retrieving size of ", profile)
        try:
            print(os.getcwd())
            result = subprocess.run(["ninja", f"size_gpslogger-{profile}"],
                                    check=True,
                                    cwd=self.run_dir,
                                    stderr=subprocess.PIPE,
                                    stdout=subprocess.PIPE)
            content = result.stdout.decode().strip('\n').split('\n')[-1]
            ret = content.split()[:3]
            return ret
        except subprocess.CalledProcessError as e:
            print("cmd:", e.cmd)
            print("Ret:", e.returncode)
            print("out:", e.stdout.decode())
            print("err:", e.stderr.decode())
            raise e

    def flash(self, profile):
        print("flashing ", profile)
        subprocess.run(["ninja", f"flash_gpslogger-{profile}"], cwd=self.run_dir, check=True)
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
            GPSLoggerExp.trigger_reset()
            time.sleep(0.1)

    def get_time(self, profile):
        reset_count = self.inputs.reset_count.value
        p = Process(target=GPSLoggerExp.resetting, args=(reset_count+10,))
        p.start()
        with serial.Serial(self.inputs.serial_device.value, 115200 * 8,
                           timeout=0.3*reset_count) as ser:
            content = b""
            while content.count(b"$$$") < reset_count:
                content += ser.read(10)
        p.join()
        blocks = content.decode('utf-8').split('###\r\n')


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
        for profile in self.inputs.profiles:
            print("starting profile ", profile)
            text, data, bss = self.get_size(profile)
            self.outputs.results[f"{profile}/code size"] = text
            self.outputs.results[f"{profile}/data size"] = data
            self.outputs.results[f"{profile}/bss size"] = bss
            print(f"{profile} text: {text}, data: {data}, bss: {bss}")

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
    args, unknown = parser.parse_known_args()
    experiment = GPSLoggerExp(run_dir=args.run_dir)
    dirname = experiment(unknown)
    print(dirname)

    for out in experiment.outputs.items():
        real = out[1].path
        link = os.path.join(os.path.dirname(out[1].path), '..', out[1].basename)
        print(f'creating symlink at "{link}" pointing to "{real}"')
        if os.path.islink(link):
            os.unlink(link)
        os.symlink(real, link)


if __name__ == "__main__":
    main()
