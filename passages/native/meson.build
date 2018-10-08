llvm_dep = dependency('llvm', version : '>=6.0')

native_pass_pyx_cpp = custom_target('native_pass_pyx',
  output : 'native_pass_pyx.cpp',
  input : 'native_passage.pyx',
  command : [cython, '-I', '../subprojects/libgraph', '@INPUT@', '--cplus', '-3', '-o', '@OUTPUT@'],
)

plib = py3_inst.extension_module('native_passage',
  native_pass_pyx_cpp,
  'llvm.cpp',
  dependencies : [py3_inst.dependency(), libgraph, llvm_dep]
)

pinc = include_directories('.')
pass_dep = declare_dependency(link_with : plib,
  include_directories : pinc,
  dependencies : libgraph)

passdir = meson.current_build_dir()
