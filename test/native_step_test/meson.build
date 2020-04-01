test('native-steps',
  py3_inst,
  args : files('native_steps.py'),
  env : [python_path]
)

test('bb-split',
  py3_inst,
  args: [files('run_test_step.py'), 'BBSplitTest', gpslogger_application],
  env: [python_path]
)

test('comp-insert',
  py3_inst,
  args: [files('run_test_step.py'), 'CompInsertTest', gpslogger_application],
  env: [python_path]
)

test('fn-single-exit',
  py3_inst,
  args: [files('run_test_step.py'), 'FnSingleExitTest', freertos_multi_exit],
  env: [python_path]
)

test('llvm-map',
  py3_inst,
  args: [files('run_test_step.py'), 'LLVMMapTest', gpslogger_application],
  env: [python_path]
)
