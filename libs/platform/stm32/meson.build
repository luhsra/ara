lib_platform_targets = []
subdir('Drivers/CMSIS/')
subdir('Drivers/STM32F1xx_HAL_Driver/')

src_files = [
  'init'
]

foreach src : src_files
  obj_target = custom_target(src,
                             input: src+'.cc',
                             output: src+'.cc.o',
                             depfile: src+'.cc.dep',
                             command: clang_cpp+
                                      libs_includes +
                                      ld_flags +
                                      obj_flags +
                                      clang_flags)
  lib_platform_targets += obj_target

endforeach



default_linkerscript = meson.current_source_dir() + '/linkerscript.ld'

run_target('cat_serial', command:[join_paths(meson.current_source_dir(), 'cat_serial.sh')])
