test('native-steps',
  py3_inst,
  args : files('native_steps.py'),
  env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('bb-split',
  py3_inst,
  args: [files('bb_split.py'), 'freertos', gpslogger_targets],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('fn-single-exit',
  py3_inst,
  args: [files('fn_single_exit.py'), 'freertos', freertos_multi_exit],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)
