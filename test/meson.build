test('dependency-resolving',
        py3_inst,
        args : files('dependency_resolving.py'),
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('multiple-configured-steps',
        py3_inst,
        args : files('multiple_configured_steps.py'),
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('priority-inversion',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('priority_inversion.json'), freertos_priority_inversion],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('invalid-mutex',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('invalid_mutex.json'), freertos_invalid_mutex],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('start-scheduler-relation',
        py3_inst,
        args : [files('start_scheduler_relation.py'), 'FreeRTOS', files('start_scheduler_relation.json'), freertos_start_scheduler_relation],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('topological-sort',
        py3_inst,
        args : [files('topological_sort.py'), 'FreeRTOS', files('topological_sort.json'), freertos_topological_sort],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('deadlock',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('deadlock.json'), freertos_deadlock],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('invalid-semaphore',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('invalid_semaphore.json'), freertos_invalid_semaphore],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('eventlist-warning',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('eventgroup.json'), freertos_eventgroup],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('critical-region-detection',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('critical_region_detection.json'), freertos_critical_region_detection],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
        # TODO Test auf ABB3 nicht im kritischen Bereich
)

test('invalid-isr-syscall',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('invalid_isr_syscall.json'), freertos_invalid_isr_syscall],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)
test('loop-detection',
        py3_inst,
        args : [files('loop_detection.py'), 'FreeRTOS', files('loop_detection.json'), freertos_loop_detection],
        env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('oil-parsing',
  py3_inst,
  args : [files('oil.py'), osek_oiltest[0], osek_oiltest[1]],
  env : ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

test('ir-reader',
  py3_inst,
  args: [files('ir_reader.py'), 'FreeRTOS', files('empty.json'), gpslogger_targets],
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)
test('ir-reader-false-syntax',
  py3_inst,
  args: [files('ir_reader.py'), 'FreeRTOS', files('empty.json'), gpslogger_targets, files('ir_reader.false_syntax.ll')],
  should_fail: true,
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)
test('ir-reader-multiple-symbols',
  py3_inst,
  args: [files('ir_reader.py'), 'FreeRTOS', files('empty.json'), gpslogger_targets, files('ir_reader.multiple_symbols.ll')],
  should_fail: true,
  env: ['PYTHONPATH=' + ':'.join([source_dir, stepdir, graphdir])]
)

subdir('native_step_test')
