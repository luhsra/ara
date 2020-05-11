freertos_includes = ['-I', meson.current_source_dir()]
if get_option('arch') == 'arm'
  subdir('arm')
else
  error('unknown arch')
endif

libs_includes += ['-I', meson.current_source_dir()]
