if get_option('arch') == 'arm'
  subdir('stm32')
  libplatform_target = custom_target('libplatform.a',
									 input: lib_platform_targets,
									 output: 'libplatform.a',
									 command: ar_cmd)
  ld_flags += ['-Wl,-L' + meson.current_build_dir(), '-lplatform']
  libs_targets += libplatform_target


endif
