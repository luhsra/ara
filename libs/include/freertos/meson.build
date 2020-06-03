freertos_includes = ['-I', meson.current_source_dir()]
if get_option('arch') == 'arm'
  subdir('arm')
elif get_option('arch') == 'i386'
  subdir('i386')
else
  error('unknown arch')
endif

libs_includes += ['-I', meson.current_source_dir()]
