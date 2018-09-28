project('ara-graph', 'cpp',
  default_options : ['warning_level=3', 'cpp_std=c++17'])

cython = find_program('cython')
py3_mod = import('python')
py3_inst = py3_mod.find_installation('python3')

llvm_dep = dependency('llvm', version : '>=6.0')

graph_pyx_cpp = custom_target('graph_pyx',
  output : 'graph_pyx.cpp',
  input : 'graph.pyx',
  command : [cython, '@INPUT@', '--cplus', '-o', '@OUTPUT@'],
)

slib = py3_inst.extension_module('graph',
  'graph.h', graph_pyx_cpp,
  dependencies : [py3_inst.dependency(), llvm_dep]
)

inc = include_directories('.')
graph_dep = declare_dependency(link_with : slib,
  include_directories : inc)

graphdir = meson.current_build_dir()
