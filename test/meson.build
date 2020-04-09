# store py3inst for recovery
real_py3_inst = py3_inst
# using a disabler stops the execution but not syntax and existence checks
if get_option('disable_step_tests')
  py3_inst = disabler()
endif

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

test('loop-detection',
        py3_inst,
        args : [files('loop_detection.py'), files('loop_detection.json'), freertos_loop_detection],
        env : [python_path]
)

test('oil-parsing',
  py3_inst,
  args : [files('oil.py'), osek_oiltest[0], osek_oiltest[1]],
  env : [python_path]
)

test('ir-reader',
  py3_inst,
  args: [files('ir_reader.py'), files('empty.json'), gpslogger_application],
  env: [python_path]
)
test('ir-reader-false-syntax',
  py3_inst,
  args: [files('ir_reader.py'), files('empty.json'), files('ir_reader.false_syntax.ll')],
  should_fail: true,
  env: [python_path]
)
test('ir-reader-multiple-symbols',
  py3_inst,
  args: [files('ir_reader.py'), files('empty.json'), files('ir_reader.multiple_symbols.ll')],
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
  args: [files('syscall.py'), files('syscall.json'), freertos_syscall],
  env: [python_path]
)

test('icfg',
  py3_inst,
  args: [files('icfg.py'), files('icfg.json'), freertos_icfg],
  env: [python_path]
)

subdir('native_step_test')

# restore using previously stored value
py3_inst = real_py3_inst
