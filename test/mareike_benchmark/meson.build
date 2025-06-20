# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Inside parrot/build
# Setup config + Run a test(s):
# meson configure -Dara:autosar_benchmark=true && ninja
# meson test ara_tasks_1 ara_angle_2
# Run suite (with 36 cores):
# meson test --suite automotive_benchmark_ara -j 36

# Inside ara/test/mareike_benchmark
# Parse testlog into csv, plot [and save to png]
# python3 meson_parser.py ../../../../build/meson-logs/testlog.txt res_tmp.csv && python3 plot.py res_tmp.csv [--save out.png]

# At the end reset config
# meson configure -Dara:autosar_benchmark=false
foreach app : autosar_generated_targets_pi4
    # Filter
    if not app['path'].contains('automotive_benchmark/testsuit')
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
    test('ara_' + app['name'] + '_' + app['variant'].to_lower(),
        py3_inst,
        args: [files('run_ara.py'), app['full_name']],
        env: [python_path],
        depends: [ara_py, app['ll_pi4']],
        suite: 'automotive_benchmark_ara',
        timeout: 7000 # 20 60 600 1000 7000
    )

    # 2. Deploy binary and run ara on pi4
    test('pi_' + app['name'] + '_' + app['variant'].to_lower(),
        py3_inst,
        args: [files('run_pi.py'), app['full_name']],
        env: [python_path],
        depends: [ara_py],
        is_parallel: false,
        suite: 'automotive_benchmark_pi',
        timeout: 180
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