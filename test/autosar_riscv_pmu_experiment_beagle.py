#!/usr/bin/env python3

import subprocess
import re
import json
import time
from pathlib import Path


class BeagleVExperiment: 
    
    def __init__(self, targets, build_dir, restart_cmd, remote_host, iterations): 
        self.target = target
        self.build_dir = build_dir
        self.restart_cmd = restart_cmd
        self.remote_host = remote_host
        self.iterations = iterations

    def __compile_with_ninja(self):   
        print("Compiling with ninja.")
        try:
            ninja_result = subprocess.run(
                f'ninja {self.target}',
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                shell=True, 
                cwd=self.build_dir, 
                check=True)
        except subprocess.CalledProcessError as e:
            print("ninja failed", e.stderr)
            raise (e)
        return ninja_result.stdout.decode('utf-8')
    
    def __restart_board(self):
        print("Restarting board.")
        # restart board # from 45 
        try:
            restart_result = subprocess.run(
                self.restart_cmd, 
                shell=True, 
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                check=True)
        except subprocess.CalledProcessError as e:
            print("restart failed", e.stderr)
            raise (e)
        return restart_result.stdout.decode('utf-8')
     
    def __measure(self):
        print(f"Measuring {self.target}")
         
        ninja_result = self.__compile_with_ninja()
        restart_result = self.__restart_board()
        
        with open(Path(__file__).parent / "beagle_serial_console.py") as f:
            remote_serial = f.read()
        assert "'" not in remote_serial, "Forbidden chars" # ' character breaks SSH command
        
        remote_command = f"source serial/bin/activate; python3 -c '{remote_serial}'"
        
        print("Measuring. This might take a while...")
        try:
            serial_result = subprocess.run(
                            ["ssh", self.remote_host, remote_command],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT,
                            check=True)
        except subprocess.CalledProcessError as e:
            print("Remote Serial Connection failed.", e.stderr)
            raise (e)
        
        return {
            "ninja_result": ninja_result,
            "restart_result": restart_result,
            "serial_result": serial_result.stdout.decode('utf-8')
            }

    def __evaluate(self, serial_result):       
        pattern = re.compile(r"(?P<type>[a-z]+)\[(?P<idx>.*?)\]=(?P<value>\d+)")
        
        values = {}
        diffs = {}

        raw_application_output = serial_result.split("NEWRUN", maxsplit=1)[1]
        for line in raw_application_output.splitlines():
            if line.startswith("RAW"):
                continue
            
            match = pattern.fullmatch(line)
            if not match:
                continue 
            
            type = match["type"]
            idx = match["idx"]
            val = int(match["value"])
            
            if type == "val":
                values[int(idx)] = val
            elif type =="d":
                diffs[idx] = val
            else: 
                assert False # should be impossible
        
        return {
            "values": values,
            "diffs": diffs
        }
    
    def run(self):
        results = []
        for i in range(self.iterations):
            print(f"Starting iteration {i} for application {self.target}")
            log_results = self.__measure()
            evaluation = self.__evaluate(log_results["serial_result"])
            
            results.append({
                "logs": log_results,
                "evaluation": evaluation
            })
        return results
        

if __name__ == "__main__":
    
    targets = [
        #"tftp_autosar_multicore_andreas_pmu_get_spinlock_riscv",
        "tftp_autosar_multicore_andreas_pmu_ipi_send_riscv",
        #"tftp_autosar_multicore_andreas_pmu_ipi_recv_riscv",
    ]
    
    BUILD_DIR = "/srv/scratch/mau.hoeppner/Bachelorthesis/ara-test/ara/build"
    RESTART_CMD = "/srv/scratch/mau.hoeppner/Bachelorthesis/power2.py NET2 CYCLE"
    REMOTE_HOST ="lab-pc60"
    REPEATS = 2
    
    timestr = time.strftime("%Y%m%d-%H%M%S")
    
    for target in targets:
        experiment = BeagleVExperiment(target, BUILD_DIR, RESTART_CMD, REMOTE_HOST, REPEATS)
        
        run_results = []
        
        experiment_results = experiment.run()
        for result in experiment_results:
            print(result["evaluation"])
            print(result["logs"])
            
            run_results += [result["evaluation"]] 
        
        filename = target + "_" + timestr + ".json"
        print(filename)
        
        with open(filename, "w") as f:
            json.dump(run_results, f, indent= 4)
            
        
            
            
        
            
            
# Assumptions:
#   - source serial/bin/activate funktioniert 
#   - remote pc per ssh erreichbar
#   - remote pc env hat pySerial dependency
#
