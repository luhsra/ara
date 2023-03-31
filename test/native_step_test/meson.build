# SPDX-FileCopyrightText: 2019 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

run_test_cstep = files('run_test_step.py')

test('native-steps',
    py3_inst,
    args: files('native_steps.py'),
    env: [python_path],
    suite: ['analysis', 'preproc']
)

test('cfg-optimize',
    py3_inst,
    args: [run_test_cstep, 'CFGOptimizeTest', freertos_optimization],
    env: [python_path],
    suite: ['analysis', 'preproc']
)

test('fn-single-exit',
    py3_inst,
    args: [run_test_cstep, 'FnSingleExitTest', freertos_multi_exit],
    env: [python_path],
    suite: ['analysis', 'preproc']
)

test('llvm-map',
    py3_inst,
    args: [run_test_cstep, 'LLVMMapTest', freertos_icfg],
    env: [python_path],
    suite: ['analysis', 'preproc']
)

# bb-split and comp-insert are in parrot
