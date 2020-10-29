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

    test('multiple-configured-steps',
        py3_inst,
        args: files('multiple_configured_steps.py'),
        env: [python_path],
        suite: 'steps'
    )

    test('oil-parsing',
        py3_inst,
        args: [files('oil.py'), osek_oiltest[0], osek_oiltest[1]],
        env: [python_path],
        suite: 'steps'
    )

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
        suite: 'steps'
    )

    subdir('native_step_test')
endif
