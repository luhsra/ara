# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import subprocess

def main():
    """Run a target of the automotive benchmark suite."""

    # sys.argv[0] is name of script
    py3_inst = sys.argv[1]
    ara_py = sys.argv[2]
    ll_pi4 = sys.argv[3]
    oil = sys.argv[4]
    full_name = sys.argv[5]
    do_debug = sys.argv[6] == 'true'
    
    os = "AUTOSAR"
    settings = "../subprojects/ara/settings/autosar_arm_automotive_benchmark.json"
    opt_name = full_name + "_noopt"
    mod_pi4_ll = opt_name + "_mod.pi4.ll"
    autosar_pi4 = opt_name + "_autosar.pi4.cc"
    timing = "BB"

    command = [py3_inst, ara_py, ll_pi4, "--os", os, "--oilfile", oil, 
               "--ir_output", mod_pi4_ll, "--step-settings", settings,
               "--generator_output", autosar_pi4, "--timing", timing, 
               "--no_colors", "True"]

    if do_debug:
        print(f"Command:\n{' '.join(command)}\n")

    with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        if do_debug:
            stdout_log = process.stdout.read().decode("utf-8")
            stderr_log = process.stderr.read().decode("utf-8")
            print(f"Errors:\n{stderr_log}\n")
            print(f"StdOut:\n{stdout_log}\n")
            
    # Test ok
    sys.exit(0)

if __name__ == "__main__":
    main()
