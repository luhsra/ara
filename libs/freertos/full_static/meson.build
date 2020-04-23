src_files = [
  'tasks',
  'queue',
]

obj_targets = []
foreach src : src_files
  obj_target = custom_target(src,
                             input: src+'.c',
                             output: src+'.c.o',
                             depfile: src+'.dep',
                             command: clang_c+
                                      libs_includes +
                                      ld_flags +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target

  set_variable('libfreertos_full_static_'+src, obj_target)
endforeach

obj_targets += libfreertos_vanilla_croutine
obj_targets += libfreertos_vanilla_event_groups
obj_targets += libfreertos_vanilla_list
obj_targets += libfreertos_vanilla_timers
obj_targets += libfreertos_vanilla_port


libfreertos_full_static = custom_target('libfreertos_full_static.a',
                                        input: obj_targets,
                                        output: 'libfreertos_full_static.a',
                                        command: ar_cmd)

libfreertos_instances_full_static = libfreertos_full_static

ld_flags += ['-Wl,-L' + meson.current_build_dir()]
