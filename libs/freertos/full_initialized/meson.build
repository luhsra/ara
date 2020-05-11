libs_includes += ['-I', meson.current_source_dir()+'/']
target_prefix = 'libfreertos_instances_full_initialized'
src_files = [
  'tasks',
  'queue',
]

obj_targets = []
libfreertos_src_files_instances_full_initialized = []
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

  set_variable(target_prefix + '_' +src, obj_target)
  libfreertos_src_files_instances_full_initialized += files(src+'.c')

endforeach

obj_targets += libfreertos_vanilla_croutine
obj_targets += libfreertos_vanilla_event_groups
obj_targets += libfreertos_vanilla_list
obj_targets += libfreertos_vanilla_timers
obj_targets += libfreertos_vanilla_port

libfreertos_src_files_instances_full_initialized += libfreertos_src_vanilla_croutine
libfreertos_src_files_instances_full_initialized += libfreertos_src_vanilla_event_groups
libfreertos_src_files_instances_full_initialized += libfreertos_src_vanilla_list
libfreertos_src_files_instances_full_initialized += libfreertos_src_vanilla_timers
libfreertos_src_files_instances_full_initialized += libfreertos_src_vanilla_port


ar_target = custom_target(target_prefix + '.a',
                          input: obj_targets,
                          output: target_prefix + '.a',
                          command: ar_cmd)

set_variable(target_prefix, ar_target)
