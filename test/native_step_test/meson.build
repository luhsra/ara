test('native-steps',
  py3_inst,
  args : files('native_steps.py'),
  env : [python_path]
)

test('bb-split',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'BBSplitTest', gpslogger_targets],
  env: [python_path]
)

test('comp-insert',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'CompInsertTest', gpslogger_targets],
  env: [python_path]
)

test('fn-single-exit',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'FnSingleExitTest', freertos_multi_exit],
  env: [python_path]
)

test('llvm-map',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'LLVMMapTest', gpslogger_targets],
  env: [python_path]
)
