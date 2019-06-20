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
