graph_pyx_cpp = custom_target('graph_pyx',
	output : 'graph_pyx.cpp',
	input : 'graph.pyx',
	command : [cython, '@INPUT@', '--cplus', '-o', '@OUTPUT@'],
)

libgraph = py3_inst.extension_module('graph',
	'graph.h', graph_pyx_cpp, 'graph.cc',
	dependencies : [py3_inst.dependency(), llvm_dep]
)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with : libgraph,
                               include_directories : graph_inc)

graphdir = meson.current_build_dir()

graph_cython_inc = meson.current_source_dir()
