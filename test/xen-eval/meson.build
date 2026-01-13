# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Usage:
    # Goto parrots build folder and run:
    # ninja
    # Single Test/ Multiple Test/ Suite (with 36 cores)
        # meson test ara-xen-eval-minial
        # meson test ara-xen-eval-minimal ara-xen-eval-hypercall
        # meson test --suite ara-xen-eval

    # Goto "cd ../subprojects/ara/test/xen-eval":
    # Parse testlog into csv, plot [and save to png]
        # python3 ara_meson_parser.py ../../../../build/meson-logs/testlog.txt res-ara.csv

foreach app : xen_testcases
    # 1. Compile and run ara
    test('ara-xen-eval-' + app['name'],
        py3_inst,
        args: [files('run_ara.py'), app['name']],
        env: [python_path],
        depends: [ara_py, rebuild_lls],
        suite: 'ara-xen-eval',
        timeout: 100 
    )

endforeach
