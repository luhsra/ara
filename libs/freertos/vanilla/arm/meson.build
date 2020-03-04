src_files = [
  'port'
]

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

  set_variable('libfreertos_vanilla_'+src, obj_target)
endforeach

