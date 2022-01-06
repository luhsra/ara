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
        depends: ara_py,
        suite: 'steps'
    )

    test('icfg',
        py3_inst,
        args: [files('icfg.py'), files('icfg.json'), freertos_icfg],
        env: [python_path],
        depends: ara_py,
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

    test('instance_graph_stats',
        py3_inst,
        args: [files('instance_graph_stats.py'), files('instance_graph_stats.json'), freertos_interaction],
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )

    test('ir-reader',
        py3_inst,
        args: [files('ir_reader.py'), files('empty.json'), gpslogger_application],
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )
    test('ir-reader-false-syntax',
        py3_inst,
        args: [files('ir_reader.py'), files('empty.json'), files('ir_reader.false_syntax.ll')],
        should_fail: true,
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )
    test('ir-reader-multiple-symbols',
        py3_inst,
        args: [files('ir_reader.py'), files('empty.json'), files('ir_reader.multiple_symbols.ll')],
        should_fail: true,
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )


    lock_files = {
                   'autosar_multicore_locks_a': files('locks_a.json'),
                   'autosar_multicore_locks_b': files('locks_b.json'),
                   'autosar_multicore_locks_c': files('locks_c.json'),
                   'autosar_multicore_locks_d': files('locks_d.json'),
                   'autosar_multicore_locks_e': files('locks_e.json'),
                 }
    foreach app: autosar_targets
      if app['full_name'] in lock_files
           locks = lock_files[app['full_name']]
      elif app.has_key('locks')
             locks = app['locks']
      else
        continue
      endif
      test('lock_elision_' + app['full_name'],
          py3_inst,
          args: [files('lock_elision.py'), locks, app['ll'], app['oil']],
          env: [python_path],
          depends: ara_py,
          suite: ['steps', 'lock_elision']
      )
    endforeach

    foreach app: autosar_targets
      if not app.has_key('trace')
        continue
      endif
      test('multisse_' + app['full_name'],
          py3_inst,
          args: [files('multisse.py'), app['sys_test'], app['ll'], app['oil']],
          env: [python_path],
          depends: ara_py,
          suite: ['steps', 'multisse']
      )
    endforeach

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

    test('src-loc',
        py3_inst,
        args: [files('src_loc.py'), files('src_loc.json'), freertos_src_loc],
        env: [python_path],
        depends: ara_py,
        suite: 'steps'
    )

    foreach elem : autosar_targets
      if elem['core'] != 'singlecore'
        continue
      endif

      test('sse_' + elem['full_name'],
          py3_inst,
          args: [files('sse.py'), elem['sys_test'], elem['ll'], elem['oil']],
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
