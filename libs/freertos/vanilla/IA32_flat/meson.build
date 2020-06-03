src_files = [
  'port'
]
freertos_src_list += src_files

foreach src : src_files
  obj_target = custom_target(src,
                             input: src+'.c',
                             output: src+'.c.o',
                             depfile: src+'.dep',
                             command: clang_c+
                                      libs_includes +
                                      freertos_default_config +
                                      ld_flags +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target

  set_variable('libfreertos_vanilla_'+src, obj_target)
  set_variable('libfreertos_src_vanilla_'+src, files(src+'.c'))
  libfreertos_src_files_vanilla += files(src+'.c')
  libfreertos_src_files_passthrough += files(src+'.c')
endforeach
