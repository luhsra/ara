test('native-steps',
  py3_inst,
  args : files('native_steps.py'),
  env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('bb-split',
  py3_inst,
  args: [files('run_test_step.py'), 'freertos', 'BBSplitTest', gpslogger_targets],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('comp-insert',
  py3_inst,
  args: [files('run_test_step.py'), 'freertos', 'CompInsertTest', gpslogger_targets],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('fn-single-exit',
  py3_inst,
  args: [files('fn_single_exit.py'), 'freertos', freertos_multi_exit],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)
