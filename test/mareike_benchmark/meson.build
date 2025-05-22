# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Template for other test
# run with 'meson test dummytest'
test('mydummy',
    py3_inst,
    args: [files('dummy.py'), 'param'],
    env: [python_path],
    suite: 'mareike',
    timeout: 5      # in seconds
)
# test('dummy2',
#     py3_inst,
#     args: [files('dummy.py'), 'param'],
#     env: [python_path],
#     suite: 'mareike',
#     timeout: 5      # in seconds
# )
# meson test --suite ara:mareike_benchmark
# meson test --suite mareike_benchmark
# müssten gehen, aber dann wird alles ara ausgeführt
