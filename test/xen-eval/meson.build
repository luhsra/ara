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
    name = app['name']
    n = 'hypersse_xen'
    suits = []
    timeout = 60
    if 'testsuite' not in app
        message(f'@name@ is not part of any testsuite.')
    elif app['testsuite'] == '10s'
        # suits = [f'@n@_10s', f'@n@_100s', f'@n@_1h', f'@n@']
        suits = [f'@n@_full', f'@n@']
        timeout = 20 
    elif app['testsuite'] == '100s'
        # suits = [f'@n@_100s', f'@n@_1h', f'@n@']
        suits = [f'@n@_full']
        timeout = 100 
    # currently not used
    # elif app['testsuite'] == '1h'
    #     suits = [f'@n@_1h', f'@n@']
    #     timeout = 3600 
    # elif app['testsuite'] == 'full'
    #     suits = [f'@n@']
    #     timeout = 0     # no timeout
    elif app['testsuite'] == 'none'
        continue
    endif
    test('ara-xen-eval-' + name,
                py3_inst,
                args: [files('run_ara.py'), name],
                env: [python_path],
                depends: [ara_py, rebuild_lls],
                suite: suits,
                timeout: timeout)
endforeach