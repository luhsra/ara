

# FreeRTOS examples
freertos_src_dir = join_paths(meson.current_source_dir(), 'FreeRTOS')

freertos_targets = []

disabled_tests = [
  'argument_load',
  'c',
  'dead_code',
  'deadlock',
  'dominator',
  'eventgroup',
  'f',
  'g',
  'invalid_isr_syscall',
  'invalid_mutex',
  'invalid_semaphore',
  'loop_detection',
  'multi_exit',
  'ospert',
  'priority_inversion',
  'simple_queue_send',
  'thesis_print',
  'topological_sort',
]
foreach app : ['a',
               'abb_merge',
               'argument_load',
               'c',
               'critical_region_detection',
               'dead_code',
               'deadlock',
               'dominator',
               'eventgroup',
               'f',
               'g',
               'icfg',
               'invalid_isr_syscall',
               'invalid_mutex',
               'invalid_semaphore',
               'loop_detection',
               'multi_exit',
               'ospert',
               'priority_inversion',
               'sse',
               'start_scheduler_relation',
               'syscall',
               'simple_print',
               'simple_delay',
               'simple_queue_send',
               'thesis_print',
               'topological_sort']
  app_vanilla_ll = custom_target('freertos-' + app,
                            input : ['FreeRTOS/' + app + '.cc'],
                            output : ['freertos-' + app + '.ll'],
                            depfile : 'freertos-' + app + '.ll.dep',
                            command : clang_cpp +
                                      libs_includes +
                                      ir_flags +
                                      clang_flags)
  set_variable('freertos_' + app.underscorify(), app_vanilla_ll)

  o_target = custom_target('freertos-' + app + '.o',
                            input : app_vanilla_ll,
                            output : ['freertos-' + app + '.ll.o'],
                            command : llc_cmd)

  named_elf_targets = []
  elf_targets = []
  foreach t : ara_gen_freertos_targets
    name_prefix = 'freertos-' + app + '-' + t
    ara_target = custom_target(name_prefix + '-os',
                               input: app_vanilla_ll,
                               depfile: name_prefix+ '-os.cc.dep',
                               output: [name_prefix + '-os.cc',
                                        name_prefix + '-os.cc.startup.s',
                                        name_prefix + '-modifiedapp.ll'],
                               command: get_variable('ara_gen_cmd_' + t)
                              )
    os_target = [ara_target[0], ara_target[1]]
    app_aramodified_ll = ara_target[2]

    os_ll_target = custom_target(name_prefix + '-os.cc.ll',
                                 input : os_target,
                                 output : name_prefix + '-os.cc.ll',
                                 depfile : name_prefix + '-os.cc.ll.dep',
                                 command : clang_cpp +
                                           libs_includes +
                                           ir_flags +
                                           clang_flags)

    app_os = custom_target(name_prefix + '-app_os.ll',
                           input: [app_aramodified_ll, os_ll_target],
                           output: name_prefix + '-os_app.ll',
                           command: llvm_link_cmd)

    lto_app_os = custom_target(name_prefix + '-lto_app_os.ll',
                               input: app_os,
                               output: name_prefix + '-lto_os_app.ll',
                               command: llvm_opt_cmd)

    lto_o = custom_target(name_prefix + '-lto_app_os.o',
                          input: lto_app_os,
                          output: name_prefix + '-lto_os_app.ll.o',
                          command: llc_cmd)

    lto_elf = custom_target(name_prefix + '.lto.elf',
                            input: [lto_o,
                                    os_target[1], # startup.s
                                    libs_targets,
                                    get_variable('libfreertos_'+t)],
                            output: name_prefix + '.lto.elf',
                            depfile: name_prefix + '.lto.elf.dep',
                            command: clang_cpp +
                                     libs_includes +
                                     ld_flags +
                                     clang_flags)

    elf_target = custom_target(name_prefix + '.elf',
                               input: [o_target,
                                       os_target,
                                       libs_targets,
                                       get_variable('libfreertos_'+t)],
                               output: name_prefix + '.elf',
                               depfile: name_prefix + '.elf.dep',
                               command: clang_cpp +
                                        libs_includes +
                                        ld_flags +
                                        clang_flags)

    bin_target = custom_target(name_prefix + '.bin',
                               input: [elf_target],
                               output: name_prefix + '.bin',
                               command: objcopy_cmd)

    lto_bin_target = custom_target(name_prefix + '.lto.bin',
                                   input: [lto_elf],
                                   output: name_prefix + '.lto.bin',
                                   command: objcopy_cmd)

    run_target('flash_' + name_prefix, command: ['st-flash', 'write', bin_target, '0x8000000'])
    run_target('flash_' + name_prefix + '.lto', command: ['st-flash', 'write', lto_bin_target, '0x8000000'])
    run_target('size_' + name_prefix, command: [size, elf_target])
    run_target('run_gdb_hw_' + name_prefix, command: [gdb_hw_script, elf_target])
    run_target('run_qemu_' + name_prefix, command: [qemu_cmd, elf_target])
    run_target('run_gdb_qemu_' + name_prefix, command: [gdb_qemu_cmd, elf_target])
    elf_targets += elf_target
    elf_targets += lto_elf
    named_elf_targets += [t, elf_target]
    named_elf_targets += [t+'.lto', lto_elf]

    if get_option('disable_qemu_tests') or  app in disabled_tests
      py = disabler()
    else
      py = py3_inst
    endif
    test('run_qemu_' + name_prefix,
         py,
         args: [qemu_test_runner,
                qemu_cmd,
                app,
                elf_target,
               ],
         env: [python_path],
         workdir: freertos_src_dir,
        )


  endforeach

  run_target('compare_nm-' + app, command: [compare_nm,  named_elf_targets])
  run_target('compare_size-' + app, command: [size, elf_targets])
  run_target('compare_time-' + app, command: [compare_time, app], depends: elf_targets)

  freertos_targets += app_vanilla_ll
endforeach

# gpslogger is special
subdir('FreeRTOS/GPSLogger')
freertos_targets += gpslogger_targets

subdir('FreeRTOS/SmartPlug')
freertos_targets += smartplug_targets

freertos_examples = run_target('freertos-examples',
                               command: nop,
                               depends: freertos_targets)

# OSEK examples

osek_includes = ['-I', join_paths(meson.current_source_dir(), 'OSEK', 'source', 'os')]
osek_folder = 'OSEK'

osek_targets = []
foreach app : [['a',                     'a.oil'],
               ['b',                     'oilfile.oil'],
               ['c',                     'oilfile.oil'],
               ['coptermok',             'coptermok.oil'],
               ['copter-without-alarms', 'copter-without-alarms.oil'],
               ['oiltest',               'oiltest.oil']]
  app_vanilla_ll = custom_target('osek-' + app[0],
                            input : [join_paths([osek_folder, app[0] + '.cc'])],
                            output : ['osek-' + app[0] + '.ll'],
                            depfile : 'osek-' + app[0] + '.ll.dep',
                            command : clang_cpp +
                                      libs_includes +
                                      ir_flags +
                                      clang_flags)
    set_variable('osek_' + app[0].underscorify(), [app_vanilla_ll, files(join_paths([osek_folder, app[1]]))])
    osek_targets += app_vanilla_ll
endforeach

osek_examples = run_target('osek-examples',
                           command: nop,
                           depends: osek_targets)

examples = run_target('examples',
                      command: nop,
                      depends: [osek_targets, freertos_targets])
