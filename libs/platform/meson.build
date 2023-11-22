lib_platform_src_files = []
libplatform_includes = []
if arm_enabled
  subdir('stm32')
  libplatform_target = custom_target('libplatform.a',
                                     input: lib_platform_targets,
                                     output: 'libplatform.a',
                                     command: [arm_ar, ar_args])
  arm_libs_targets = [libplatform_target]
endif
