libsra_proj = subproject('ara-libsra')

libplatform_link_with = libplatform_proj.get_variable('libplatform_link_with')
libplatform_includes = []
libplatform_include_directories = libplatform_proj.get_variable('libplatform_include_directories')
foreach include_dir : libplatform_include_directories
  libplatform_includes += ['-I', include_dir]
endforeach

libsra_includes = []
foreach dir : libsra_proj.get_variable('libsra_include_directories')
  libsra_includes += ['-I', dir]
endforeach

freertos_proj = subproject('freertos')
freertos_default_config = freertos_proj.get_variable('default_config')
freertos_includes = []
foreach dir : freertos_proj.get_variable('header_dirs') + freertos_proj.get_variable('arm_header_dirs')
  freertos_includes += ['-I', dir]
endforeach

app_flags = ['-DconfigINCLUDE_ALL_DECLS=1']
arm_ld_flags = libplatform_proj.get_variable('arm_ld_flags')
stm32_clang_flags = libplatforms_proj.get_variable('stm32_clang_flags')
arm_compiler_flags = clang_flags + arm_clang_flags + arm_ld_flags + stm32_clang_flags

# these apps are not meant to ever run on real hardware, but are used for unit tests etc.
# they are only compiled to IR
ir_apps = [
  {'file': 'abb_merge'},
  {'file': 'argument_load'},
  {'file': 'cfg_pic'},
  {'file': 'condition'},
  {'file': 'critical_region_detection'},
  {'file': 'deadlock'},
  {'file': 'dominator'},
  {'file': 'eventgroup'},
  {'file': 'foo'},
  {'file': 'function_pointer'},
  {'file': 'icfg'},
  {'file': 'instances'},
  {'file': 'invalid_isr_syscall'},
  {'file': 'invalid_mutex'},
  {'file': 'invalid_semaphore'},
  {'file': 'interaction'},
  {'file': 'isrs'},
  {'file': 'loop_detection'},
  {'file': 'multi_exit'},
  {'file': 'optimization'},
  {'file': 'ospert'},
  {'file': 'priority_inversion'},
  {'file': 'rtas20_example'},
  {'file': 'visualization_thesis_example'},
  {'file': 'src_loc'},
  # {'file': 'simple_queue_send'},
  {'file': 'sse'},
  {'file': 'svf'},
  {'file': 'start_scheduler_relation'},
  {'file': 'syscall'},
  {'file': 'system_relevant_functions'},
  # {'file': 'thesis_print'},
  {'file': 'topological_sort'},
  {'file': 'value_analysis_struct'},
]

# these apps are meant to run on real hardware and are compiled into an elf
# name should be max 10 chars long
hw_apps = [
  {'file': 'simple_print', 'name': 's_print' },
  {'file': 'simple_delay', 'name': 's_delay' },
  {'file': 'simple_queue_send', 'name': 's_queue_send' },
  {'file': 'simple_mutex', 'name': 's_mutex' },
  {'file': 'simple_mutex_constructor', 'name': 's_mut_cstrt' },
  # {'file': 'simple_pios_modules', 'name': 'pios_mod'}, # mini version of the librepilot/pios module system for task creation
  {'file': 'simple_lazy_create', 'name': 'lazy_create' },
  {'file': 'simple_runtime_create', 'name': 'run_create' },
  {'file': 'timing_xTaskCreate-preScheduler', 'name': 't_task_pre' },
  {'file': 'timing_xTaskCreate-postScheduler', 'name': 't_task_post' },
  {'file': 'timing_xQueueCreate', 'name': 't_queue' },
]

freertos_config = ['-I', fs.parent(freertos_default_config.full_path())]

arm_freertos_apps = []
foreach app : ir_apps + hw_apps
  app_name = app['file']
  if app.has_key('name')
    app_name = app['name']
  endif
  app_vanilla_ll = custom_target('freertos-' + app_name,
                            input : [app['file'] + '.cc'],
                            output : ['freertos-' + app['file'] + '.ll'],
                            depfile : 'freertos-' + app['file'] + '.ll.dep',
                            command : clang_cpp +
                                      app_flags +
                                      libs_includes +
                                      libplatform_includes +
                                      freertos_includes +
                                      libsra_includes +
                                      freertos_config +
                                      ir_flags +
                                      arm_compiler_flags)
  set_variable('freertos_' + app['file'].underscorify(), app_vanilla_ll)
  # prepare data for generated apps
  # see the parrot project for more information
  if app in hw_apps
    arm_freertos_apps += [{
      'name': 'fr-' + app_name,
      'll': app_vanilla_ll,
      'freertos_config': freertos_default_config,
      'additional_libs': [libplatform_link_with],
    }]
  endif

endforeach
