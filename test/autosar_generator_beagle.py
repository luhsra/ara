#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Andreas Kässens
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Note: init_test must be imported first
from init_test import init_test, fail_if

import sys
import subprocess

from pathlib import Path

def main():
    """Test for successful AUTOSAR image creation."""

    #TARGET = 'tftp_autosar_multicore_andreas_cores_4_riscv'
    #BUILD_DIR = "/srv/scratch/mau.hoeppner/Bachelorthesis/ara/build"
    REMOTE_HOST ="lab-pc60"


    executable = sys.argv[1:]

    print("running", executable)
    print("Deploying to tftp")
    with subprocess.Popen(executable, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:

        stdout_log = process.stdout.read().decode('utf-8')
        stderr_log = process.stderr.read().decode('utf-8')

        # log the results
        print(stderr_log)
        print(stdout_log)


    # restart board # from 45 
    try:
        subprocess.run('/srv/scratch/mau.hoeppner/Bachelorthesis/power2.py NET2 CYCLE', shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print("ninja failed", e.stderr)
        raise (e)
    
    with open(Path(__file__).parent / "serial_console.py") as f:
        remote_serial = f.read()
    assert "'" not in remote_serial, "Forbidden chars"
    
    command = f"source serial/bin/activate; python3 -c '{remote_serial}'"
    try:
        result = subprocess.run(
                        ["ssh", REMOTE_HOST, command],
                        capture_output=True,
                        check=False)
    except subprocess.CalledProcessError as e:
        print("SSH FAILED", e.stderr)
        raise (e)
    print(result)
    outp = result.stdout.decode("UTF-8").split("NEWRUN")
    for idx, run in enumerate(outp):
        print("Run", idx)
        lines = run.split("\n")
        for line in lines:
            print(line)


    # result is in stdout
    result = False
    for line in lines:
        if line == "Tests finished: ALL OK":
            result = True
            break

    fail_if(result == False, "Runtime test failed")



if __name__ == '__main__':
    main()
