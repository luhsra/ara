# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import subprocess
import time
from pathlib import Path
from os import path

def main():
    """Deploy a target on the evaluation pi for the automotive benchmark suite."""

    # sys.argv[0] is name of script
    full_name = sys.argv[1]

    # Check if ARA already run for this testcase
    check_cmd = ["ninja", "subprojects/ara/appl/AUTOSAR/" + full_name + "_noopt_mod.pi4.ll", "-n"]
    with subprocess.Popen(check_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout_log = process.stdout.read().decode("utf-8")
        stderr_log = process.stderr.read().decode("utf-8")
        if not stdout_log.startswith("ninja: no work to do."):
            print(f"Not analysed by ARA, first run \"meson test --suite automotive_benchmark_ara\"")
            print(f"Needs:{stderr_log}\n{stdout_log}")
            print("SKIPPED!")
            print("This should never happen with the current configuration.")
            sys.exit(77) # means skipped for meson

    tftp_cmd = ["ninja", "ara@@tftp_" + full_name + "_noopt_pi4", "-v"]
    with subprocess.Popen(tftp_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout_log = process.stdout.read().decode("utf-8")
        stderr_log = process.stderr.read().decode("utf-8")
        print(f"Ninja Tftp-Log:\n{stderr_log}\n{stdout_log}END-LOG")

    # Start/Restart Pi
    subprocess.run("ssh lab-pc00 'python power.py NET3 OFF'", shell=True, check=True)
    time.sleep(10)
    subprocess.run("ssh lab-pc00 'python power.py NET3 ON'", shell=True, check=True)

    # Read python into remote_serial
    with open(Path(__file__).parent / "read_serial_console.py") as f:
        remote_serial = f.read()
    
    # Exectute remotly
    host = "lab-pc67"
    dev = "/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A50285BI-if00-port0"
    nix_cmd = f"nix-shell -p python313Packages.pyserial --run"
    command = f"'python read_serial_console.py {dev}'"
    result = subprocess.run(["ssh", host, nix_cmd, command], capture_output=True, check=False)
    
    # debug print as addition to meson-logs/testlog.txt
    # print(f"---\n{result.stdout.decode("UTF-8", "ignore")}\n---")

    # Parse results
    suc = False
    for l in result.stdout.decode("UTF-8", "ignore").splitlines():
        print(l)

        if l.startswith("- All task finished, passed!"):
            print("All tasks run.")
            suc = True
                        
        if l.startswith("- Task(s) got blocked, failed!"):
            print("Tasks got blocked.")
    if suc:
        sys.exit(0)
    else:
        print("Did not find results in serial logs!")
        sys.exit(1)

if __name__ == "__main__":
    main()
