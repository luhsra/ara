test('graph-lib',
        py3_inst,
        args : files('test_graph.py'),
        env : [python_path]
)

test('dependency-resolving',
        py3_inst,
        args : files('dependency_resolving.py'),
        env : [python_path]
)

test('multiple-configured-steps',
        py3_inst,
        args : files('multiple_configured_steps.py'),
        env : [python_path]
)

test('priority-inversion',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('priority_inversion.json'), freertos_priority_inversion],
        env : [python_path]
)

test('invalid-mutex',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('invalid_mutex.json'), freertos_invalid_mutex],
        env : [python_path]
)

test('start-scheduler-relation',
        py3_inst,
        args : [files('start_scheduler_relation.py'), 'FreeRTOS', files('start_scheduler_relation.json'), freertos_start_scheduler_relation],
        env : [python_path]
)

test('topological-sort',
        py3_inst,
        args : [files('topological_sort.py'), 'FreeRTOS', files('topological_sort.json'), freertos_topological_sort],
        env : [python_path]
)

test('deadlock',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('deadlock.json'), freertos_deadlock],
        env : [python_path]
)

test('invalid-semaphore',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('invalid_semaphore.json'), freertos_invalid_semaphore],
        env : [python_path]
)

test('eventlist-warning',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('eventgroup.json'), freertos_eventgroup],
        env : [python_path]
)

test('critical-region-detection',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('critical_region_detection.json'), freertos_critical_region_detection],
        env : [python_path]
        # TODO Test auf ABB3 nicht im kritischen Bereich
)

test('invalid-isr-syscall',
        py3_inst,
        args : [files('validation.py'), 'FreeRTOS', files('invalid_isr_syscall.json'), freertos_invalid_isr_syscall],
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
