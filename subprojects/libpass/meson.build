project('ara-pass', 'cpp',
  default_options : ['warning_level=3', 'cpp_std=c++17'])

cython = find_program('cython')
py3_mod = import('python')
py3_inst = py3_mod.find_installation('python3')

libgraph = dependency('libgraph', fallback: ['libgraph', 'graph_dep'])

# TODO, this should not be here
llvm_dep = dependency('llvm', version : '>=6.0')

pass_pyx_cpp = custom_target('pass_pyx',
  output : 'pass1_pyx.cpp',
  input : 'pass1.pyx',
  command : [cython, '-I', '../subprojects/libgraph', '@INPUT@', '--cplus', '-o', '@OUTPUT@'],
)

plib = py3_inst.extension_module('pass1',
  'pass.h', pass_pyx_cpp,
  dependencies : [py3_inst.dependency(), libgraph, llvm_dep]
)

pinc = include_directories('.')
pass_dep = declare_dependency(link_with : plib,
  include_directories : pinc,
  dependencies : libgraph)

passdir = meson.current_build_dir()
