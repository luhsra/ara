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
        depends: [ara_py],
        suite: 'ara-xen-eval',
        timeout: 100 
    )

    # # 2. Deploy binary and run ara on pi4
    # test('pi_' + app['name'] + '_' + app['variant'].to_lower(),
    #     py3_inst,
    #     args: [files('run_pi.py'), app['full_name']],
    #     env: [python_path],
    #     depends: [ara_py],
    #     # depends: [ara_py, app['ll_pi4_mod_noopt']],
    #     is_parallel: false,
    #     suite: 'automotive_benchmark_pi',
    #     timeout: 180
    # )
endforeach
