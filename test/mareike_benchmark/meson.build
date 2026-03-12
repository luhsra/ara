# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Usage:
    # Goto parrots build folder and run:
    # meson configure -Dara:autosar_benchmark=true && ninja
    # Single Test/ Multiple Test/ Suite (with 36 cores)
        # meson test ara_tasks_1
        # meson test ara_tasks_1 ara_angle_1
        # meson test --suite automotive_benchmark_ara -j 36

    # Goto "ara/test/mareike_benchmark":
    # Parse testlog into csv, plot [and save to png]
        # python3 ara_meson_parser.py ../../../../build/meson-logs/testlog.txt res-ara.csv && python3 ara_plot.py res-ara.csv [--save out.png]
        # python3 pi_meson_parser.py ../../../../build/meson-logs/testlog.txt res-pi.csv && python3 pi_plot.py res-pi.csv [--save out.png]

    # Reset config afterwards:
    # meson configure -Dara:autosar_benchmark=false

    # Bash wrapper in "ara/test/mareike_benchmark"
    # ./ara_run.sh
    # ./pi_run.sh

foreach app : autosar_generated_targets_pi4
    # Filter
    if not app['path'].contains('automotive_benchmark/testsuit')
        continue
    endif
    # Could add an own option here
    if app['opt'] != 'noopt'
        continue
    endif

    # [FLAG] Only extended angle testing
    # if not (app['name'].contains('angle') or app['name'].contains('tasks'))
    #     continue
    # endif

    # [FLAG] Remove extended angle testing
    if app['name'].contains('angle-')
        continue
    endif

    # 1. Compile and run ara
    test('ara_' + app['name'] + '_' + app['variant'].to_lower() + '_arm',
        py3_inst,
        args: [files('run_ara.py'), app['full_name'], '_noopt_mod.pi4.ll'],
        env: [python_path],
        depends: [ara_py, app['ll_pi4']],
        suite: 'automotive_benchmark_ara_arm',
        timeout: 1000 # 20 60 600 1000 7000 86400
        # full benchmark should take arround 8h = 28000
    )

    # 2. Deploy binary and run ara on pi4
    test('pi_' + app['name'] + '_' + app['variant'].to_lower() + '_arm',
        py3_inst,
        args: [files('run_pi.py'), app['full_name']],
        env: [python_path],
        depends: [ara_py],
        # depends: [ara_py, app['ll_pi4_mod_noopt']],
        is_parallel: false,
        suite: 'automotive_benchmark_pi',
        timeout: 180
    )
endforeach


foreach app : autosar_generated_targets_riscv
    # Filter
    if not app['path'].contains('automotive_benchmark/testsuit')
        continue
    endif

    if not app['name'].contains('tasks')
        continue
    endif

    # [FLAG] Only extended angle testing
    # if not (app['name'].contains('angle') or app['name'].contains('tasks'))
    #     continue
    # endif

    # [FLAG] Remove extended angle testing
    if app['name'].contains('angle-')
        continue
    endif

    # 1. Compile and run ara
    test('ara_' + app['name'] + '_' + app['variant'].to_lower() + '_riscv',
        py3_inst,
        args: [files('run_ara.py'), app['full_name'], '_mod.riscv.ll'],
        env: [python_path],
        depends: [ara_py, app['ll_riscv']],
        suite: 'automotive_benchmark_ara_riscv',
        timeout: 300 # 20 60 600 1000 7000 86400
        # full benchmark should take arround 8h = 28000
    )

    # 2. Deploy binary and run ara on pi4
    test('beagle_' + app['name'] + '_' + app['variant'].to_lower() + '_riscv',
        py3_inst,
        args: [files('run_beagle.py'), app['full_name']],
        env: [python_path],
        depends: [ara_py],
        # depends: [ara_py, app['ll_pi4_mod_noopt']],
        is_parallel: false,
        suite: 'automotive_benchmark_beagle',
        timeout: 90
    )
endforeach

# Template for other tests
# test('dummytest',
#     py3_inst,
#     args: [files('dummy.py'), 'param'],
#     env: [python_path],
#     depends: ara_py,
#     # is_parallel: false,
#     suite: 'automotive_benchmark',
#     timeout: 5      # in seconds
# )