autosar_includes += ['-I', meson.current_source_dir() / 'generic']

if arm_enabled
  subdir('arm')
endif

if posix_enabled
  subdir('posix')
endif

subdir('generic')
