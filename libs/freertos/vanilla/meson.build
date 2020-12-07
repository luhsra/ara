src_files = [
  'croutine',
  'event_groups',
  'list',
  'queue',
  'tasks',
  'timers',
  'stream_buffer',
  'heap_1',
]
freertos_src_list = src_files
libfreertos_src_files_vanilla = []
libfreertos_src_files_passthrough = []

obj_targets = []
foreach src : src_files
  obj_target = custom_target(src,
                             input: src+'.c',
                             output: src+'.c.o',
                             depfile: src+'.dep',
                             command: clang_c+
                                      libs_includes +
                                      freertos_default_config +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target

  set_variable('libfreertos_vanilla_'+src, obj_target)
  set_variable('libfreertos_src_vanilla_'+src, files(src+'.c'))
  set_variable('libfreertos_src_passthrough_'+src, files(src+'.c'))
  libfreertos_src_files_vanilla += files(src+'.c')
  libfreertos_src_files_passthrough += files(src+'.c')
endforeach

cpp_src_files = [
]
foreach src : cpp_src_files
  obj_target = custom_target(src,
                             input: src+'.cc',
                             output: src+'.cc.o',
                             depfile: src+'.cc.dep',
                             command: clang_cpp+
                                      libs_includes +
                                      freertos_default_config +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target

  set_variable('libfreertos_vanilla_'+src, obj_target)
endforeach


if get_option('arch') == 'arm'
  subdir('arm')
elif get_option('arch') == 'i386'
  warning('i396 is not very well supported. problems are likely')
  subdir('IA32_flat')
else
  error('unknown arch')
endif

libfreertos_vanilla = custom_target('libfreertos_vanilla.a',
                                    input: obj_targets,
                                    output: 'libfreertos_vanilla.a',
                                    command: ar_cmd)
libfreertos_passthrough = libfreertos_vanilla

