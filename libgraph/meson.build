pygraph_includes = files('cgraph.pxd', 'util.pxd', 'graph.pxd')

graph_pyx_cpp = custom_target('graph_pyx',
	output : 'graph_pyx.cpp',
	input : ['graph.pyx', pygraph_includes],
	command : [cython, '@INPUT0@', '--cplus', '-o', '@OUTPUT@'],
)

libgraph = py3_inst.extension_module('graph',
	'graph.h', graph_pyx_cpp, 'graph.cc', 'cfg.cpp',
	dependencies : [py3_inst.dependency(), llvm_dep, boost_dep]
)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with : libgraph,
                               include_directories : graph_inc)

graphdir = meson.current_build_dir()

graph_cython_inc = meson.current_source_dir()
