# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import os
import subprocess

def main():
    """Run a target of the xen eval benchmark suite."""

    # sys.argv[0] is name of script
    full_name = sys.argv[1]
    target = "subprojects/ara/appl/Xen/" + full_name
    ninja_ara = ["ninja", target, "-v"]
    
    # execute ninja cmd
    with subprocess.Popen(ninja_ara, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout_log = process.stdout.read().decode("utf-8")
        stderr_log = process.stderr.read().decode("utf-8")
        print(f"Errors:\n{stderr_log}\n")
        print(f"StdOut:\n{stdout_log}\n")

    if "ERROR" in stdout_log:
        sys.exit(1)
    # Test ok
    sys.exit(0)

if __name__ == "__main__":
    main()
