if get_option('arch') == 'arm'
  subdir('arm')
elif get_option('arch') == 'posix'
  subdir('posix')
else
  warning('unknown arch')
  subdir('posix')
endif
