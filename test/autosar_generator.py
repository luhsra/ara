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


def main():
    """Test for successful AUTOSAR image creation."""

    executable = sys.argv[1:]

    print("running", executable)

    with subprocess.Popen(executable, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as process:

        stdout_log = process.stdout.read().decode('utf-8')
        stderr_log = process.stderr.read().decode('utf-8')

        # log the results
        print(stderr_log)
        print(stdout_log)

        # result is in stdout
        result = False
        for line in stdout_log.splitlines():
            if line == "Tests finished: ALL OK":
                result = True
                break

        fail_if(result == False, "Runtime test failed")



if __name__ == '__main__':
    main()
