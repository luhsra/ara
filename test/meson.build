if get_option('enable_step_tests')
    test('dependency-resolving',
        py3_inst,
        args: files('dependency_resolving.py'),
        env: [python_path],
        suite: 'steps'
    )

    test('dummy-test',
        py3_inst,
        args: [ara_py, 'empty',
               '-v',
               '--step-settings', files('dummy_settings.json')],
        suite: 'steps'
    )

    test('function-pointer',
        py3_inst,
        args: [files('function_pointer.py'), files('function_pointer.json'), freertos_function_pointer],
        env: [python_path],
        suite: 'steps'
    )

    test('icfg',
        py3_inst,
        args: [files('icfg.py'), files('icfg.json'), freertos_icfg],
        env: [python_path],
        suite: 'steps'
    )

    test('instances',
        py3_inst,
        args: [files('instances.py'), files('instances.json'), freertos_instances],
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )

    test('interactions',
        py3_inst,
        args: [files('interactions.py'), files('interactions.json'), freertos_interaction],
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )

    test('ir-reader',
        py3_inst,
        args: [files('ir_reader.py'), files('empty.json'), gpslogger_application],
        env: [python_path],
        suite: 'steps'
    )
    test('ir-reader-false-syntax',
        py3_inst,
        args: [files('ir_reader.py'), files('empty.json'), files('ir_reader.false_syntax.ll')],
        should_fail: true,
        env: [python_path],
        suite: 'steps'
    )
    test('ir-reader-multiple-symbols',
        py3_inst,
        args: [files('ir_reader.py'), files('empty.json'), files('ir_reader.multiple_symbols.ll')],
        should_fail: true,
        env: [python_path],
        suite: 'steps'
    )

    test('lock-elision',
        py3_inst,
        args: [files('lock_elision.py'), files('empty.json'), autosar_multicore_locks_a[0], autosar_multicore_locks_a[1]],
        env: [python_path],
        depends: ara_py,
        suite: ['steps', 'sse']
    )

    test('multiple-configured-steps',
        py3_inst,
        args: files('multiple_configured_steps.py'),
        env: [python_path],
        suite: 'steps'
    )

    test('recursive',
        py3_inst,
        args: [files('recursive.py'), files('recursive.json'), freertos_icfg],
        env: [python_path],
        suite: 'steps'
    )

    foreach elem : autosar_targets_with_test
      test('sse_' + elem[3],
          py3_inst,
          args: [files('sse.py'), elem[2], elem[0], elem[1]],
          env: [python_path],
          depends: ara_py,
          suite: ['steps', 'sse']
      )
    endforeach

    test('syscall',
        py3_inst,
        args: [files('syscall.py'), files('syscall.json'), freertos_syscall],
        env: [python_path],
        suite: 'steps'
    )

    test('value-analysis',
        py3_inst,
        args: [files('value_analysis.py'), files('value_analysis.json'), freertos_svf],
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )

    test('value-analysis-struct',
        py3_inst,
        args: [files('value_analysis.py'), files('value_analysis_struct.json'), freertos_value_analysis_struct],
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )

    subdir('native_step_test')
endif
