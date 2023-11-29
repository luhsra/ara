
# experiment scripts
GenericTimingExperiment = files('GenericTimingExperiment.py')
ShowGenericTimingExperiment = files('make_figures.py')
InstanceGraphExperiment = files('instance_graph_experiment.py')

libsra_proj = subproject('ara-libsra')

if arm_enabled
  ## FreeRTOS apps, we build them currently with an ARM toolchain
  arm_objcopy = toolchains.get_variable('arm_objcopy')
  arm_size = toolchains.get_variable('arm_size')
  arm_nm = toolchains.get_variable('arm_nm')

  libplatform_link_with = libplatform_proj.get_variable('libplatform_link_with')
  libplatform_includes = []
  libplatform_include_directories = libplatform_proj.get_variable('libplatform_include_directories')
  foreach include_dir : libplatform_include_directories
    libplatform_includes += ['-I', include_dir]
  endforeach

  libsra_link_with = libsra_proj.get_variable('libsra_link_with')
  libsra_include_directories = libsra_proj.get_variable('libsra_include_directories')

  app_flags = ['-DconfigINCLUDE_ALL_DECLS=1']
  # FreeRTOS examples
  freertos_src_dir = meson.current_source_dir() / 'FreeRTOS'

  freertos_targets = []

  # these apps are not meant to ever run on real hardware, but are used for unit tests etc.
  # they are only compiled to IR
  ir_apps = [
    'abb_merge',
    'argument_load',
    'cfg_pic',
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
    'isrs',
    'loop_detection',
    'multi_exit',
    'optimization',
    'ospert',
    'priority_inversion',
    'rtas20_example',
    'visualization_thesis_example',
    'src_loc',
    # 'simple_queue_send',
    'sse',
    'svf',
    'start_scheduler_relation',
    'syscall',
    'system_relevant_functions',
    #'thesis_print',
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

  if meson.version().version_compare('>=1.4.0')
    error('Please remove the horrible hack below and use the "libplatform_linkerscript.full_path()" directly.')
  endif
  libplatform_linkerscript_fixed = fs.copyfile(libplatform_linkerscript, 'libplatform.ld')

  arm_llc_flags = ['--frame-pointer=none']
  arm_ld_flags = libplatform_proj.get_variable('arm_ld_flags')
  arm_compiler_flags = clang_flags + arm_clang_flags + arm_ld_flags

  foreach app : ir_apps + hw_apps
    app_vanilla_ll = custom_target('freertos-' + app,
                              input : ['FreeRTOS/' + app + '.cc'],
                              output : ['freertos-' + app + '.ll'],
                              depfile : 'freertos-' + app + '.ll.dep',
                              command : clang_cpp +
                                        app_flags +
                                        libs_includes +
                                        libplatform_includes +
                                        arm_freertos_includes +
                                        arm_freertos_default_config +
                                        ir_flags +
                                        arm_compiler_flags)
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
      if get_option('execute_ara')
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
      else
        ara_target = disabler()
      endif
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
                                             libplatform_includes +
                                             arm_freertos_includes +
                                             arm_freertos_default_config +
                                             ir_flags +
                                             arm_compiler_flags)


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
                                           libplatform_includes +
                                           arm_freertos_includes +
                                           arm_freertos_default_config +
                                           ['-DFREERTOS_OVERRIDES="'+freertos_overrides.full_path()+'"'] +
                                           ir_flags +
                                           arm_compiler_flags)
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
                                   depends: [sparse_rle2],
                                   output: lto_prefix + '-os_app.ll',
                                   command: get_variable('llvm_lto_cmd_' + lto_version))

        lto_o = custom_target(lto_prefix + '-app_os.o',
                              input: lto_app_os,
                              output: lto_prefix + '-os_app.ll.o',
                              command: llc_cmd + arm_llc_flags)

        lto_elf = custom_target(lto_prefix + '.elf',
                                input: [lto_o,
                                        os_target[1], # startup.s
                                        libs_targets,
                                       ],
                                output: lto_prefix + '.elf',
                                depfile: lto_prefix + '.elf.dep',
                                depends: [libplatform_linkerscript_fixed, libsra_link_with, libplatform_link_with],
                                command: clang_cpp +
                                         libs_includes +
                                         ld_flags +
                                         ['-L' + fs.parent(libsra_link_with.full_path()), '-lsra'] +
                                         ['-L' + fs.parent(libplatform_link_with.full_path()), '-lplatform'] +
                                         ['-T' + libplatform_linkerscript_fixed.full_path() ] +
                                         arm_compiler_flags)

        bin_target = custom_target(lto_prefix + '.bin',
                                   input: [lto_elf],
                                   output: lto_prefix + '.bin',
                                   command: [arm_objcopy, objcopy_args])
      run_target('flash_' + lto_prefix, command: [st_flash, 'write', bin_target, '0x8000000'])
      run_target('size_' + lto_prefix, command: [arm_size, '-A', lto_elf])
      run_target('run_gdb_hw_' + lto_prefix, command: [gdb_hw_script, lto_elf])
      run_target('run_qemu_' + lto_prefix, command: [qemu_cmd, lto_elf])
      run_target('run_gdb_qemu_' + lto_prefix, command: [gdb_qemu_cmd, lto_elf])
      elf_targets += lto_elf
      named_elf_targets += [target + '-' + lto_version, lto_elf]
      profiles_list += ['--profiles', target + '-' + lto_version]

      if app not in ir_apps
        test('validate_generator_' + lto_prefix,
             py3_inst,
             args: [validate_generator_runner,
                    app,
                    target,
                    app_aramodified_ll,
                    os_target[0].full_path(),
                    lto_elf,
                   ],
             workdir: freertos_src_dir,
             suite: 'generator'
            )
        endif

      if get_option('enable_qemu_tests') and app not in ir_apps
          test('run_qemu_' + lto_prefix,
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

    run_target('compare_nm-' + app, command: [compare_nm, arm_nm.path(), named_elf_targets])
    run_target('compare_size-' + app, command: [arm_size, elf_targets])
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

  freertos_examples = run_target('freertos-examples',
                                 command: nop,
                                 depends: freertos_targets)
endif

# AUTOSAR examples
# it is POSIX only currently
if posix_enabled
  subdir('AUTOSAR')
  i4copter = autosar_singlecore_complex_isorc
  run_target('i4copter_instance_exp',
      command: [py3_inst, InstanceGraphExperiment, '--title=ARA_Instance_Graph_Experiment', '-v',
                '--llvm_ir', i4copter['ll'],
                '--oil', i4copter['oil'],
                '--os=AUTOSAR'],
      env: [python_path],
      depends: ara_py
  )

  run_target('i4copter_sse_exp',
      command: [py3_inst, InstanceGraphExperiment, '--title=ARA_SSE_Experiment', '-v',
                '--llvm_ir', i4copter['ll'],
                '--oil', i4copter['oil'],
                '--is_ina=False',
                '--os=AUTOSAR'],
      env: [python_path],
      depends: ara_py
  )
endif
