lib_platform_src_files = []
libplatform_includes = []
if get_option('arch') == 'arm'
  subdir('stm32')
  libplatform_target = custom_target('libplatform.a',
                                     input: lib_platform_targets,
                                     output: 'libplatform.a',
                                     command: ar_cmd)
  libs_targets += libplatform_target
endif
