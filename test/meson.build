# SPDX-FileCopyrightText: 2019 Benedikt Steinmeier
# SPDX-FileCopyrightText: 2020 Manuel Breiden
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Domenik Kuhn
# SPDX-FileCopyrightText: 2023 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

instance_graph_test = files('instance_graph.py')
instance_graph_stats = files('instance_graph_stats.py')
test_dir = meson.current_source_dir()

if get_option('build_automotive_benchmark')
  # Call all testcases in this folder, contains the autosar_benchmark_suite
  subdir('mareike_benchmark')
endif

run_test_cstep = files('native_step_test/run_test_step.py')

if get_option('build_step_tests')
  dummy = files('empty.json')

  if arm_enabled
    test('create-abbs',
      py3_inst,
      args: [files('abb.py'), files('abb.json'), freertos_abb_merge],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )

    test('dependency-resolving',
      py3_inst,
      args: files('dependency_resolving.py'),
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )

    test('dummy-test',
      py3_inst,
      args: [ara_py, 'empty',
            '-v',
            '--os', 'FreeRTOS',
            '--step-settings', files('dummy_settings.json')],
      suite: ['analysis', 'preproc']
    )

    test('equations',
      py3_inst,
      args: [files('equations.py')],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'multisse']
    )

    test('function-pointer',
      py3_inst,
      args: [files('function_pointer.py'), files('function_pointer.json'), freertos_function_pointer],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )

    test('icfg',
      py3_inst,
      args: [files('icfg.py'), files('icfg.json'), freertos_icfg],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )


    foreach mode : ['flowsensitive', 'flowinsensitive', 'mixed']
      test('instances-' + mode,
          py3_inst,
          args: [
            files('instances.py'),
            files('instances.json'),
            freertos_instances,
            mode
          ],
          env: [python_path, 'RUST_LOG=debug'],
          depends: ara_py,
          suite: ['analysis', 'sia']
      )
    endforeach

    test('instances-isrs',
      py3_inst,
      args: [
        files('instances.py'),
        files('isrs.json'),
        freertos_isrs,
        'mixed'],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'sia']
    )

    test('interactions',
      py3_inst,
      args: [files('interactions.py'), files('interactions.json'), freertos_interaction],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'sia']
    )

    test('instance_graph_stats',
      py3_inst,
      args: [files('instance_graph_stats.py'), files('instance_graph_stats.json'), freertos_interaction, 'FreeRTOS'],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'sia']
    )

    test('src-loc',
      py3_inst,
      args: [files('src_loc.py'), files('src_loc.json'), freertos_src_loc],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )

    test('syscall',
      py3_inst,
      args: [files('syscall.py'), files('syscall.json'), freertos_syscall],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )

    test('value-analysis',
      py3_inst,
      args: [files('value_analysis.py'), files('value_analysis.json'), freertos_svf],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )

    test('value-analysis-struct',
      py3_inst,
      args: [files('value_analysis.py'), files('value_analysis_struct.json'), freertos_value_analysis_struct],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'preproc']
    )

    subdir('native_step_test')


  endif

  test('ir-reader-false-syntax',
    py3_inst,
    args: [files('ir_reader.py'), dummy, files('ir_reader.false_syntax.ll')],
    should_fail: true,
    env: [python_path],
    depends: ara_py,
    suite: ['analysis', 'preproc']
  )
  test('ir-reader-multiple-symbols',
    py3_inst,
    args: [files('ir_reader.py'), dummy, files('ir_reader.multiple_symbols.ll')],
    should_fail: true,
    env: [python_path],
    depends: ara_py,
    suite: ['analysis', 'preproc']
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
    if app.has_key('testsuit_extra')
      testsuit_extra = app['testsuit_extra']
    else
      testsuit_extra = []
    endif
    test('lock_elision_' + app['full_name'],
      py3_inst,
      args: [files('lock_elision.py'), locks, app['ll'], app['oil']],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'multisse', 'lock_elision'] + testsuit_extra
    )
    if app.has_key('sys_timings')
      test('lock_elision_with_timings_' + app['full_name'],
        py3_inst,
        args: [files('timed_lock_elision.py'), locks, app['ll'], app['oil'], app['sys_timings']],
        env: [python_path],
        depends: ara_py,
        suite: ['analysis', 'multisse', 'lock_elision', 'timings']
      )
    endif
  endforeach

  foreach app: autosar_targets
    if app['core'] != 'multicore' or not app.has_key('mtrace')
      continue
    endif
    if app.has_key('testsuit_extra')
      testsuit_extra = app['testsuit_extra']
    else
      testsuit_extra = []
    endif
    test('multisse_' + app['full_name'],
      py3_inst,
      args: [files('multisse.py'), app['sys_test'], app['ll'], app['oil']],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'multisse'] + testsuit_extra
    )
  endforeach

  foreach app: autosar_targets
    if not app.has_key('ttrace')
      continue
    endif
    if app.has_key('testsuit_extra')
      testsuit_extra = app['testsuit_extra']
    else
      testsuit_extra = []
    endif
    test('multisse_with_timings_' + app['full_name'],
      py3_inst,
      args: [files('multisse.py'), app['time_test'], app['ll'], app['oil'], app['sys_timings']],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'multisse', 'timings'] + testsuit_extra
    )
  endforeach

  ad = autosar_multicore_timing_artificial_delay
  test('multisse_artificial_delay_short',
    py3_inst,
    args: [files('multisse.py'), ad['short_delay'], ad['ll'], ad['oil'], ad['sys_timings'], '1'],
    env: [python_path],
    depends: ara_py,
    suite: ['analysis', 'multisse', 'timings']
  )
  test('multisse_artificial_delay_long',
    py3_inst,
    args: [files('multisse.py'), ad['long_delay'], ad['ll'], ad['oil'], ad['sys_timings'], '19'],
    env: [python_path],
    depends: ara_py,
    suite: ['analysis', 'multisse', 'timings']
  )

  test('multiple-configured-steps',
    py3_inst,
    args: files('multiple_configured_steps.py'),
    env: [python_path],
    depends: ara_py,
    suite: ['analysis', 'preproc']
  )

  foreach app : autosar_targets
    if app['full_name'] == 'autosar_singlecore_pairwise_pairwise'
      test('pairwise',
        py3_inst,
        args: [files('pairwise.py'), dummy, app['ll'], app['oil']],
        env: [python_path],
        depends: ara_py,
        suite: ['analysis']
      )
    endif
    if app['full_name'] == 'autosar_singlecore_pairwise_pairwise_fail'
      test('pairwise-fail',
        py3_inst,
        args: [files('pairwise.py'), dummy, app['ll'], app['oil']],
        env: [python_path],
        should_fail: true,
        depends: ara_py,
        suite: ['analysis']
      )
    endif
  endforeach

  foreach app : autosar_targets
    if app['core'] != 'singlecore'
      continue
    endif
    test('sse_' + app['full_name'],
      py3_inst,
      args: [files('sse.py'), app['sys_test'], app['ll'], app['oil']],
      env: [python_path],
      depends: ara_py,
      suite: ['analysis', 'sse']
    )
  endforeach

endif


if get_option('build_generator_tests')
  # system runtime test for generator
  if posix_enabled
    foreach app : autosar_generated_targets_posix
      test('autosar_generator_posix_' + app['full_name'],
        py3_inst,
        args: [files('autosar_generator.py'), app['run_cmd_posix']],
        env: [python_path],
        depends: ara_py,
        is_parallel: false,
        suite: ['autosar_generator', 'autosar_generator_posix']
      )
    endforeach
  endif

  if arm_enabled
    foreach app : autosar_generated_targets_pi4
      if app['path'].contains('automotive_benchmark')
          continue
      endif
      if app['path'].contains('complex')
          continue
      endif

      test('autosar_generator_pi4_' + app['full_name'],
        py3_inst,
        args: [files('autosar_generator.py'), app['run_cmd_pi4_noopt']],
        env: [python_path],
        depends: ara_py,
        is_parallel: false,
        suite: ['autosar_generator', 'autosar_generator_pi4']
      )
    endforeach
  endif

  if riscv_enabled
    foreach app : autosar_generated_targets_riscv
      test('autosar_generator_riscv_' + app['full_name'],
        py3_inst,
        args: [files('autosar_generator.py'), app['run_cmd_riscv']],
        env: [python_path],
        depends: [ara_py, app['app_image_riscv']],
        is_parallel: false,
        suite: ['autosar_generator', 'autosar_generator_riscv']
      )
    endforeach

    foreach app : autosar_generated_targets_riscv
      test('autosar_generator_beaglev_' + app['full_name'],
        py3_inst,
        args: [files('autosar_generator_beagle.py'), app['tftp_cmd_riscv']],
        env: [python_path],
        depends: [ara_py, app['app_image_riscv_bin']],
        is_parallel: false,
        suite: ['autosar_generator_riscv_beagle'],
        timeout: 300 # Don't want to stop before serial connection times out
      )
    endforeach
  endif
endif


# Call all testcases in this folder
if get_option('build_hypersse_xen')
  message('Including tests for "build_hypersse_xen"')
  subdir('xen-eval')
endif


