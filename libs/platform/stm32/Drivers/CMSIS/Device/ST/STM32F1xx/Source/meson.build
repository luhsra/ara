
src_files = ['system_stm32f1xx.c']

obj_targets = []
foreach src : src_files
  lib_platform_src_files += files(src)
  obj_target = custom_target(src,
                             input: src,
                             output: src+'.o',
                             depfile: src+'.dep',
                             command: clang_c+
                                      libs_includes +
                                      ld_flags +
                                      obj_flags +
                                      clang_flags)
  lib_platform_targets += obj_target
  obj_targets += obj_target
endforeach

libstm_hal_target = custom_target('cmsis.ar',
                          input: obj_targets,
                          output: 'libcmsis.a',
                          command: ar_cmd)


# ld_flags += ['-Wl,-L' + meson.current_build_dir()]
