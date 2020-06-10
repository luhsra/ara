libsra_objs = []

subdir('generic')
if get_option('arch') == 'arm'
  subdir('arm')
else
  # assert(false, 'unknown arch ')
  libsra_ar = ''
endif


libsra_ar = custom_target('libsra.a',
                          input: libsra_objs,
                          output: 'libsra.a',
                          command: ar_cmd)

ld_flags += ['-Wl,-L' + meson.current_build_dir()]
