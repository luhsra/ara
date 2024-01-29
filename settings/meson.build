ara_settings = meson.current_source_dir()

llc_flags = [
  '--function-sections',
  '--data-sections',
]
llc_cmd = [llc, '-filetype=obj', '-o', '@OUTPUT@', '@INPUT@', ] + llc_flags

llvm_link_cmd = [ara_link, '-S', '-o', '@OUTPUT@', '@INPUT@',]

llvm_opt_flags = [
  # '-time-passes',
  # '-Og',
  '-O2',
]
llvm_opt = toolchains.get_variable('llvm_opt')
llvm_opt_cmd = [llvm_opt, '-S', '-o', '@OUTPUT@', '@INPUT@'] + llvm_opt_flags

objcopy_args = ['-Obinary', '@INPUT@', '@OUTPUT@']
