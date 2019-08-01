test('native-steps',
  py3_inst,
  args : files('native_steps.py'),
  env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('bb-split',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'BBSplitTest', gpslogger_targets],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('comp-insert',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'CompInsertTest', gpslogger_targets],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('fn-single-exit',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'FnSingleExitTest', freertos_multi_exit],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('llvm-map',
  py3_inst,
  args: [files('run_test_step.py'), 'FreeRTOS', 'LLVMMapTest', gpslogger_targets],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)
