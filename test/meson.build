test('dependency-resolving',
        py3_inst, args : files('dependency_resolving.py'),
        env : [python_path]
)

test('multiple-configured-steps',
        py3_inst,
        args : files('multiple_configured_steps.py'),
        env : [python_path]
)

test('loop-detection',
        py3_inst,
        args : [files('loop_detection.py'), 'FreeRTOS', files('loop_detection.json'), freertos_loop_detection],
        env : [python_path]
)

test('oil-parsing',
  py3_inst,
  args : [files('oil.py'), osek_oiltest[0], osek_oiltest[1]],
  env : [python_path]
)

test('ir-reader',
  py3_inst,
  args: [files('ir_reader.py'), 'FreeRTOS', files('empty.json'), gpslogger_targets],
  env: [python_path]
)
test('ir-reader-false-syntax',
  py3_inst,
  args: [files('ir_reader.py'), 'FreeRTOS', files('empty.json'), gpslogger_targets, files('ir_reader.false_syntax.ll')],
  should_fail: true,
  env: [python_path]
)
test('ir-reader-multiple-symbols',
  py3_inst,
  args: [files('ir_reader.py'), 'FreeRTOS', files('empty.json'), gpslogger_targets, files('ir_reader.multiple_symbols.ll')],
  should_fail: true,
  env: [python_path]
)

test('cfg_prep',
   py3_inst,
   args: [files('../ara.py'), gpslogger_targets, '--step-settings', files('cfg_prep.json'), '--log-level', 'debug'],
   env : [python_path]
)

test('cfg_prep_no_args',
   py3_inst,
   args: [files('../ara.py'), gpslogger_targets, '--step-settings', files('cfg_prep_no_args.json'), '--log-level', 'debug'],
   should_fail: true,
   env : [python_path]
)

test('gps_stats',
   py3_inst,
   args: [files('../ara.py'), gpslogger_targets, '--step-settings', files('cfg_stats.json'), '--log-level', 'info'],
   env : [python_path]
)

test('gps_stats_no_passes',
   py3_inst,
   args: [files('../ara.py'), gpslogger_targets, '--step-settings', files('cfg_stats_no_passes.json'), '--log-level', 'info'],
   env : [python_path]
)

test('smart_stats',
   py3_inst,
   args: [files('../ara.py'), smartplug_targets, '--step-settings', files('cfg_stats.json'), '--log-level', 'info'],
   env : [python_path]
)

test('smart_stats_no_passes',
   py3_inst,
   args: [files('../ara.py'), smartplug_targets, '--step-settings', files('cfg_stats_no_passes.json'), '--log-level', 'info'],
   env : [python_path]
)

test('copter_stats',
   py3_inst,
   args: [files('../ara.py'), osek_coptermok[0], '--oilfile', osek_coptermok[1], '--step-settings', files('cfg_stats.json'), '--log-level', 'info'],
   env : [python_path]
)

test('copter_stats_no_passes',
   py3_inst,
   args: [files('../ara.py'), osek_coptermok[0], '--oilfile', osek_coptermok[1], '--step-settings', files('cfg_stats_no_passes.json'), '--log-level', 'info'],
   env : [python_path]
)

test('dummy-test',
   py3_inst,
   args: [files('../ara.py'), 'empty',
          '-v',
          '--step-settings', files('dummy_settings.json')],
   env : [python_path]
)

test('syscall',
  py3_inst,
  args: [files('syscall.py'), 'FreeRTOS', files('syscall.json'), freertos_syscall],
  env: [python_path]
)

test('icfg',
  py3_inst,
  args: [files('icfg.py'), 'FreeRTOS', files('icfg.json'), freertos_icfg],
  env: [python_path]
)

subdir('native_step_test')
