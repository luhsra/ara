app_flags = ['-DconfigINCLUDE_ALL_DECLS=1',
             ]


# FreeRTOS examples
freertos_src_dir = join_paths(meson.current_source_dir(), 'FreeRTOS')

freertos_targets = []

# these apps are not meant to ever run on real hardware, but are used for unit tests etc.
# they are only compiled to IR
ir_apps = [
  'a',
  'abb_merge',
  'argument_load',
  'c',
  'critical_region_detection',
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
  'optimization',
  'ospert',
  'priority_inversion',
  # 'simple_queue_send',
  'sse',
  'start_scheduler_relation',
  'syscall',
  'thesis_print',
  'topological_sort',
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
                                        name_prefix + '-modifiedapp.ll'],
                               command: get_variable('ara_gen_cmd_' + target)
                              )
    os_target = [ara_target[0], ara_target[1]]
    app_aramodified_ll = ara_target[2]

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
                                    get_variable('libfreertos_' + target)],
                            output: name_prefix + '.lto.elf',
                            depfile: name_prefix + '.lto.elf.dep',
                            command: clang_cpp +
                                     libs_includes +
                                     ld_flags +
                                     ['-lsra'] +
                                     clang_flags)

    elf_target = custom_target(name_prefix + '.elf',
                               input: [o_target,
                                       os_target,
                                       libs_targets,
                                       get_variable('libfreertos_' + target)],
                               output: name_prefix + '.elf',
                               depfile: name_prefix + '.elf.dep',
                               command: clang_cpp +
                                        libs_includes +
                                        freertos_default_config +
                                        libplatform_default_config +
                                        ld_flags +
                                        ['-lsra'] +
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
    named_elf_targets += [target, elf_target]
    named_elf_targets += [target+'.lto', lto_elf]

    if get_option('enable_qemu_tests') and app not in ir_apps
        test('run_qemu_' + name_prefix,
             py3_inst,
             args: [qemu_test_runner,
                    qemu_cmd,
                    app,
                    elf_target,
                   ],
             workdir: freertos_src_dir,
             suite: 'qemu',
             is_parallel: false,
            )
    endif


  endforeach

  run_target('compare_nm-' + app, command: [compare_nm, nm.path(), named_elf_targets])
  run_target('compare_size-' + app, command: [size, elf_targets])
  run_target('compare_time-' + app, command: [compare_time, meson.build_root(), app], depends: elf_targets)

  freertos_targets += app_vanilla_ll
endforeach

# gpslogger is special
subdir('FreeRTOS/GPSLogger')
freertos_targets += gpslogger_application

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

# AUTOSAR examples
subdir('AUTOSAR')


examples = run_target('examples',
                      command: nop,
                      depends: [osek_targets, freertos_targets])
