autosar_includes += ['-I', meson.current_source_dir()]

src_files = [
  'test',
]

obj_targets = []

foreach src : src_files
  obj_target = custom_target(
    src + '.cc',
    input: src+'.cc',
    output: src+'.cc.o',
    depfile: src+'.dep',
    command:
      clang_cpp +
      posix_clang_flags +
      autosar_includes +
      posix_autosar_includes +
      ld_flags +
      obj_flags +
      clang_flags)
  obj_targets += obj_target
endforeach

posix_libautosar_test = custom_target(
  'posix_libautosar_test',
  input: obj_targets,
  output: 'libautosar_test.a',
  command: [posix_ar, ar_args])
