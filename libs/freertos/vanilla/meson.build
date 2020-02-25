src_files = [
  'croutine',
  'event_groups',
  'list',
  'queue',
  'tasks',
  'timers',
  'heap_1',
]

obj_targets = []
foreach src : src_files
  obj_target = custom_target(src,
                             input: src+'.c',
                             output: src+'.c.o',
                             depfile: src+'.dep',
                             command: clang_c+
                                      libs_includes +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target

  set_variable('libfreertos_vanilla_'+src, obj_target)
endforeach

cpp_src_files = [
    'statistics',
]
foreach src : cpp_src_files
  obj_target = custom_target(src,
                             input: src+'.cc',
                             output: src+'.cc.o',
                             depfile: src+'.cc.dep',
                             command: clang_cpp+
                                      libs_includes +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target

  set_variable('libfreertos_vanilla_'+src, obj_target)
endforeach


if get_option('arch') == 'arm'
  subdir('arm')
else
  error('unknown arch')
endif

libfreertos_vanilla = custom_target('libfreertos_vanilla.a',
                                    input: obj_targets,
                                    output: 'libfreertos_vanilla.a',
                                    command: ar_cmd)

ld_flags += ['-Wl,-L' + meson.current_build_dir()]
