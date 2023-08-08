#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Note: init_test must be imported first
from init_test import init_test


def main():
    """Test for correct interaction detection."""
    config = {"steps": ["PairwiseCheck"],
              "logger": {"StepManager": "info"}}
    inp = {"oilfile": lambda argv: argv[3]}
    import sys
    print(sys.argv)
    _ = init_test(extra_config=config, extra_input=inp, os_name="AUTOSAR")


if __name__ == '__main__':
    main()
