# currently, we support only ARM compilation
# TODO refactor to also support other architectures
# TODO merge this with https://scm.sra.uni-hannover.de/research/freertos
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
                             command: clang_c +
                                      arm_clang_flags +
                                      libs_includes +
                                      arm_freertos_default_config +
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
                             command: clang_cpp +
                                      arm_clang_flags +
                                      libs_includes +
                                      arm_freertos_default_config +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target

  set_variable('libfreertos_vanilla_'+src, obj_target)
endforeach


subdir('arm')

# subdir('IA32_flat') <- only a stub

libfreertos_vanilla = custom_target('libfreertos_vanilla.a',
                                    input: obj_targets,
                                    output: 'libfreertos_vanilla.a',
                                    command: [arm_ar, ar_args])
libfreertos_passthrough = libfreertos_vanilla

