ara_settings = meson.current_source_dir()

llvm_link_cmd = toolchains.get_variable('llvm_link_cmd')

llvm_opt_flags = [
  # '-time-passes',
  # '-Og',
  '-O2',
]
llvm_opt = toolchains.get_variable('llvm_opt')
llvm_opt_cmd = [llvm_opt, '-S', '-o', '@OUTPUT@', '@INPUT@'] + llvm_opt_flags

objcopy_args = ['-Obinary', '@INPUT@', '@OUTPUT@']
