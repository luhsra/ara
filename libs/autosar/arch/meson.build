autosar_includes += ['-I', meson.current_source_dir() / 'generic']

if get_option('arch') == 'arm'
  subdir('arm')
elif get_option('arch') == 'posix'
  subdir('posix')
else
  warning('unknown arch')
  subdir('posix')
endif

subdir('generic')