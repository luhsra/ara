app_flags = ['-DconfigINCLUDE_ALL_DECLS=1',
            ]

# experiment scripts
GenericTimingExperiment = files('GenericTimingExperiment.py')
ShowGenericTimingExperiment = files('make_figures.py')


# FreeRTOS examples
freertos_src_dir = join_paths(meson.current_source_dir(), 'FreeRTOS')

freertos_targets = []

# these apps are not meant to ever run on real hardware, but are used for unit tests etc.
# they are only compiled to IR
ir_apps = [
  'abb_merge',
  'argument_load',
  'condition',
  'critical_region_detection',
  'deadlock',
  'dominator',
  'eventgroup',
  'foo',
  'function_pointer',
  'icfg',
  'instances',
  'invalid_isr_syscall',
  'invalid_mutex',
  'invalid_semaphore',
  'interaction',
  'loop_detection',
  'multi_exit',
  'optimization',
  'ospert',
  'priority_inversion',
  'rtas20_example',
  # 'simple_queue_send',
  'sse',
  'svf',
  'start_scheduler_relation',
  'syscall',
  'system_relevant_functions',
  'thesis_print',
  'topological_sort',
  'value_analysis_struct',
]

# these apps are meant to run on real hardware and are compiled into an elf
hw_apps = [
  'simple_print',
  'simple_delay',
  'simple_queue_send',
  'simple_mutex',
  'simple_mutex_constructor',
  # 'simple_pios_modules', # mini version of the librepilot/pios module system for task creation
  'simple_lazy_create',
  'simple_runtime_create',
  'timing_xTaskCreate-preScheduler',
  'timing_xTaskCreate-postScheduler',
  'timing_xQueueCreate',
]


foreach app : ir_apps + hw_apps
  app_vanilla_ll = custom_target('freertos-' + app,
                            input : ['FreeRTOS/' + app + '.cc'],
                            output : ['freertos-' + app + '.ll'],
                            depfile : 'freertos-' + app + '.ll.dep',
                            command : clang_cpp +
                                      app_flags +
                                      libs_includes +
                                      freertos_default_config +
                                      libplatform_default_config +
                                      ir_flags +
                                      clang_flags)
  set_variable('freertos_' + app.underscorify(), app_vanilla_ll)

  named_elf_targets = []
  elf_targets = []
  profiles_list = []
  foreach target : ara_gen_freertos_targets
    # build standard and specialized variants for freertos
    #
    # the whole process works roughly so:
    #
    # +--------+ ARA +-------------+                     llc +----------+
    # | app.ll |---->| modified-ll |-------------------+---->|  o-file  |
    # +--------+  |  +-------------+                   |     +----------+
    #             |                                    |
    #             |  +-------------+ clang +---------+ | llvm-link +-----------+
    #             +->|    os.cc    |------>|  os.ll  |-+---------->| app_os.ll |
    #             |  +-------------+       +---------+             +-.---------+
    #             |                                                  v opt
    #             |  +-------------+                           +---------------+
    #             +->|  startup.s  |---+                       | lto_app_os.ll |
    #                +-------------+   |                       +-----.---------+
    #                                  |                             v llc
    #                                  |                       +---------------+
    #                                  |                       | lto_app_os.ll |
    #                                  |                       +-----.---------+
    #                                  +-----------------------------|
    #                                                                v clang
    #                            +----------------+  objcopy  +----------------+
    #                            | lto_app_os.bin |<----------| lto_app_os.elf |
    #                            +----------------+           +----------------+

    name_prefix = 'freertos-' + app + '-' + target
    ara_target = custom_target(name_prefix + '-os',
                               input: app_vanilla_ll,
                               depfile: name_prefix+ '-os.cc.dep',
                               output: [name_prefix + '-os.cc',
                                        name_prefix + '-os.cc.startup.s',
                                        name_prefix + '-modifiedapp.ll',
                                        name_prefix + '-os.cc.freertos_overrides.h',
                                       ],
                               command: get_variable('ara_gen_cmd_' + target)
                              )
    os_target = [ara_target[0], ara_target[1]]
    app_aramodified_ll = ara_target[2]
    freertos_overrides = ara_target[3]

    o_target = custom_target(name_prefix + '.o',
                             input : app_aramodified_ll,
                             output : name_prefix + '.ll.o',
                             command : llc_cmd)

    os_ll_target = custom_target(name_prefix + '-os.cc.ll',
                                 input : os_target,
                                 output : name_prefix + '-os.cc.ll',
                                 depfile : name_prefix + '-os.cc.ll.dep',
                                 command : clang_cpp +
                                           libs_includes +
                                           freertos_default_config +
                                           libplatform_default_config +
                                           ir_flags +
                                           clang_flags)


    # compile freertos
    freertos_ll_targets = []
    foreach src: freertos_src_list
      ll_target = custom_target(name_prefix + '-freertos_' + src,
                                input: get_variable('libfreertos_src_vanilla_' +src),
                                output: name_prefix + '-freertos_' +src + '.c.ll',
                                depfile: name_prefix + '-freertos_' +src + '.dep',
                                depends: ara_target,
                                command: clang_c +
                                         libs_includes +
                                         freertos_default_config +
                                         ['-DFREERTOS_OVERRIDES="'+freertos_overrides.full_path()+'"'] +
                                         ir_flags +
                                         clang_flags)
      freertos_ll_targets += ll_target
    endforeach

    app_os = custom_target(name_prefix + '-app_os.ll',
                           input: [app_aramodified_ll, os_ll_target, freertos_ll_targets],
                           output: name_prefix + '-os_app.ll',
                           command: llvm_link_cmd)

    foreach lto_version : ['none', 'standard', 'rle2']
      lto_prefix = name_prefix + '-' + lto_version
      lto_app_os = custom_target(lto_prefix + '-app_os.ll',
                                 input: app_os,
                                 depends: [sparse_rle, sparse_rle2],
                                 output: lto_prefix + '-os_app.ll',
                                 command: get_variable('llvm_lto_cmd_' + lto_version))

      lto_o = custom_target(lto_prefix + '-app_os.o',
                            input: lto_app_os,
                            output: lto_prefix + '-os_app.ll.o',
                            command: llc_cmd)

      lto_elf = custom_target(lto_prefix + '.elf',
                              input: [lto_o,
                                      os_target[1], # startup.s
                                      libs_targets,
                                     ],
                              output: lto_prefix + '.elf',
                              depfile: lto_prefix + '.elf.dep',
                              depend_files: default_linkerscript,
                              command: clang_cpp +
                                       libs_includes +
                                       ld_flags +
                                       ['-lsra'] +
                                       ['-T' + default_linkerscript ] +
                                       clang_flags)

      bin_target = custom_target(lto_prefix + '.bin',
                                 input: [lto_elf],
                                 output: lto_prefix + '.bin',
                                 command: objcopy_cmd)
    run_target('flash_' + lto_prefix, command: [st_flash, 'write', bin_target, '0x8000000'])
    run_target('size_' + lto_prefix, command: [size, '-A', lto_elf])
    run_target('run_gdb_hw_' + lto_prefix, command: [gdb_hw_script, lto_elf])
    run_target('run_qemu_' + lto_prefix, command: [qemu_cmd, lto_elf])
    run_target('run_gdb_qemu_' + lto_prefix, command: [gdb_qemu_cmd, lto_elf])
    elf_targets += lto_elf
    named_elf_targets += [target + '-' + lto_version, lto_elf]
    profiles_list += ['--profiles', target + '-' + lto_version]

    if get_option('enable_qemu_tests') and app not in ir_apps
        test('run_qemu_' + name_prefix,
             py3_inst,
             args: [qemu_test_runner,
                    qemu_cmd,
                    app,
                    lto_elf,
                   ],
             workdir: freertos_src_dir,
             suite: 'qemu',
             is_parallel: false,
            )
    endif
    endforeach



  endforeach

  run_target('compare_nm-' + app, command: [compare_nm, nm.path(), named_elf_targets])
  run_target('compare_size-' + app, command: [size, elf_targets])
  run_target('compare_time-' + app, command: [compare_time, meson.build_root(), app], depends: elf_targets)

  freertos_targets += app_vanilla_ll
  timing_exp_result = custom_target('analyze_timing-' + app,
                                    command: [GenericTimingExperiment, '-d', meson.current_build_dir(),
                                              '-s',
                                              '--title', 'freertos-' + app,
                                              profiles_list,
                                              '--run-dir', meson.build_root()],
                                    output: ['timing_result-freertos-' + app + '.dref',
                                             'timing_result_raw-freertos-' + app + '.dref'],
                                    console: true,
                                    depends: elf_targets)
  run_target('show-timing_result-freertos-' + app + '.dref',
             command: [#'strace',
               ShowGenericTimingExperiment,
               profiles_list,
               '--title', 'freertos-' + app,],
             depends: timing_exp_result,
            )
  run_target('show_old-timing_result-freertos-' + app + '.dref',
             command: [#'strace',
               ShowGenericTimingExperiment,
               profiles_list,
               '--title', 'freertos-' + app,],
            )
endforeach

# gpslogger is special
subdir('FreeRTOS/GPSLogger')
freertos_targets += gpslogger_application

subdir('FreeRTOS/SmartPlug')
freertos_targets += smartplug_targets

subdir('FreeRTOS/Librepilot')
freertos_targets += librepilot_application

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

# AUTOSAR examples
subdir('AUTOSAR')


examples = run_target('examples',
                      command: nop,
                      depends: [osek_targets, freertos_targets])


# run target to invoke POSIX build Makefile (rule: all)
posix_dir = join_paths(meson.current_source_dir(), 'POSIX')
run_target('POSIX',
  command: ['make', '-C', posix_dir])

# run target to remove POSIX build generated files.
run_target('POSIX-clean',
  command: ['make', '-C', posix_dir, 'clean'])

# run target to clear POSIX build directory.
# This is useful if you want to rebuild all POSIX targets without rebuilding the musl libc.
run_target('POSIX-clean-build-dir',
  command: ['make', '-C', posix_dir, 'clean-build-dir'])