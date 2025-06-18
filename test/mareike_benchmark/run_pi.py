# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import subprocess
import time
from pathlib import Path


def main():
    """Deploy a target on the evaluation pi for the automotive benchmark suite."""

    # sys.argv[0] is name of script
    full_name = sys.argv[1]
    # next come 2 commands from meson
    index = sys.argv.index("/usr/bin/python3")
    # first app_image_pi4_cmd
    app_image_pi4_cmd = sys.argv[2:index]
    # next pi4_tftp_cmd until the end
    pi4_tftp_cmd = sys.argv[index:]

    output_path = "subprojects/ara/appl/AUTOSAR/"
    
    # Check if ARA already run for this testcase
    if not Path(output_path+full_name+"_noopt_autosar.pi4.cc").is_file():
        print(f"Not analysed by ARA, first run \"meson test --suite automotive_benchmark_ara\"")
        print("SKIPPED!")
        sys.exit(77) # means skipped for meson

    print(sys.argv)
    print(app_image_pi4_cmd)
    print(pi4_tftp_cmd)
    # Build binary
    # build_cmd = ["ninja", output_path + full_name + "_noopt_pi4.bin"]
    # print(build_cmd)
    # with subprocess.Popen(build_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
    #     stdout_log = process.stdout.read().decode("utf-8")
    #     stderr_log = process.stderr.read().decode("utf-8")
    #     print(f"Errors:\n{stderr_log}\n")
    #     print(f"StdOut:\n{stdout_log}\n")

    # Build binary
    # with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
    #     stdout_log = process.stdout.read().decode("utf-8")
    #     stderr_log = process.stderr.read().decode("utf-8")
    #     print(f"Errors:\n{stderr_log}\n")
    #     print(f"StdOut:\n{stdout_log}\n")

    # Start/Restart Pi
    # subprocess.run("ssh lab-pc00 './power.py NET3 OFF'", shell=True, check=True)
    # time.sleep(10)
    # subprocess.run("ssh lab-pc00 './power.py NET3 ON'", shell=True, check=True)


    # subprocess.run("ssh lab-pc67 'minicom -D /dev/FTDI_FT232R_USB_UART_A50285BI -C out.txt'", shell=True, check=True)
    # time.sleep(10)

    # TODO
    # with open(Path(__file__).parent / "beagle_serial_console.py") as f:
    #     remote_serial = f.read()
    # assert "'" not in remote_serial, "Forbidden chars"
    
    # command = f"source serial/bin/activate; python3 -c '{remote_serial}'"
    # try:
    #     result = subprocess.run(
    #                     ["ssh", REMOTE_HOST, command],
    #                     capture_output=True,
    #                     check=False)
    # except subprocess.CalledProcessError as e:
    #     print("SSH FAILED", e.stderr)
    #     raise (e)
    # print(result)
    # outp = result.stdout.decode("UTF-8").split("NEWRUN")
    # for idx, run in enumerate(outp):
    #     print("Run", idx)
    #     lines = run.split("\n")
    #     for line in lines:
    #         print(line)


    # # result is in stdout
    # result = False
    # for line in lines:
    #     if line == "Tests finished: ALL OK":
    #         result = True
    #         break

    # subprocess.run("ssh lab-pc00 './power.py NET3 OFF'", shell=True, check=True)
    # Test ok
    sys.exit(0)

if __name__ == "__main__":
    main()
