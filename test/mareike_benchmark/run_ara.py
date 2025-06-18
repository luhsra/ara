# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import os
import subprocess

def main():
    """Run a target of the automotive benchmark suite."""

    # sys.argv[0] is name of script
    full_name = sys.argv[1]
    target = "subprojects/ara/appl/AUTOSAR/" + full_name + "_noopt_mod.pi4.ll"
    ninja_ara = ["ninja", target, "-v"]
    # set_config_cmd = ["meson", "configure", "-Dara:autosar_benchmark=true"]
    # unset_config_cmd = ["meson", "configure", "-Dara:autosar_benchmark=false"]

    # if file already exists remove it
    if os.path.exists(target):
        os.remove(target)
    
    # # set config
    # subprocess.run(set_config_cmd)
    
    # execute ninja cmd
    with subprocess.Popen(ninja_ara, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout_log = process.stdout.read().decode("utf-8")
        stderr_log = process.stderr.read().decode("utf-8")
        print(f"Errors:\n{stderr_log}\n")
        print(f"StdOut:\n{stdout_log}\n")

    # # set config back to false
    # subprocess.run(unset_config_cmd)

    # Test ok
    sys.exit(0)

if __name__ == "__main__":
    main()
