subdir('bgl')

pygraph_includes = files('cfg/__init__.pxd',
                         'cfg/abbtype.pxd',
                         'cgraph.pxd',
                         'cy_helper.pxd',
                         'graph.pxd',
                         'newgraph.pxd')

graph_pyx_cpp = custom_target('graph_pyx',
    output : 'graph_pyx.cpp',
    input : ['graph.pyx', pygraph_includes, common_cython_files],
    command : [cython, '-I', bgl_cython_inc, '-I', common_cython_inc, '@INPUT0@', '-o', '@OUTPUT@'] + cython_flags,
)

py_graph = py3_inst.extension_module('graph',
    graph_pyx_cpp, 'graph.cc', 'cfg.cpp',
    cpp_pch: 'pch/graph_pch.h',
    dependencies : [py3_inst.dependency(), llvm_dep, boost_dep, common_dep, bgl_dep]
)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with : py_graph,
                               include_directories : graph_inc)

graphdir = meson.current_build_dir()

graph_cython_inc = meson.current_source_dir()
