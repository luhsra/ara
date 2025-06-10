# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import subprocess
import time

def main():
    """Deploy a target on the evaluation pi for the automotive benchmark suite."""

    executable = sys.argv[1:]
    print("Run:", executable)

    # Build binary
    with subprocess.Popen(executable, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout_log = process.stdout.read().decode("utf-8")
        stderr_log = process.stderr.read().decode("utf-8")
        print(f"Errors:\n{stderr_log}\n")
        print(f"StdOut:\n{stdout_log}\n")

    # Start/Restart Pi
    subprocess.run("ssh lab-pc00 './power.py NET3 OFF'", shell=True, check=True)
    time.sleep(5)
    subprocess.run("ssh lab-pc00 './power.py NET3 ON'", shell=True, check=True)



    # TODO
    with open(Path(__file__).parent / "beagle_serial_console.py") as f:
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

    # Test ok
    sys.exit(0)

if __name__ == "__main__":
    main()
