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

r = run_command(py3_inst, '-c', 'import pydot as pd; print(pd.__version__)', check: true)
if r.returncode() != 0
  error('Pydot not found.')
elif r.stdout().version_compare('== 4.0.1')
  message('Pydot version good.')
else
  error('Pydot version too old, newer versions might work if they dont change their output syntax again!\nYou can still run ARA, but the graph verification might fail.')
endif

foreach app : xen_testcases
    # 1. Compile and run ara
    if not app['name'].contains('EXTRA')
        test('ara-xen-eval-' + app['name'],
            py3_inst,
            args: [files('run_ara.py'), app['name']],
            env: [python_path],
            depends: [ara_py, rebuild_lls],
            suite: 'ara-xen-eval',
            timeout: 100 
        )
    endif

endforeach
