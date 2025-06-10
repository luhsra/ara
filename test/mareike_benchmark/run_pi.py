# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import subprocess

def main():
    """Deploy a target on the evaluation pi for the automotive benchmark suite."""

    executable = sys.argv[1:]
    print("Run:", executable)

    with subprocess.Popen(executable, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:
        stdout_log = process.stdout.read().decode("utf-8")
        stderr_log = process.stderr.read().decode("utf-8")
        print(f"Errors:\n{stderr_log}\n")
        print(f"StdOut:\n{stdout_log}\n")
            
    # Test ok
    sys.exit(0)

if __name__ == "__main__":
    main()
