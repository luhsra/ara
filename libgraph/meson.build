subdir('bgl')

pygraph_includes = files('cgraph.pxd', 'newgraph.pxd', 'boost.pxd', 'graph.pxd',
                         'cfg_wrapper/__init__.pxd',
                         'cfg/__init__.pxd',
                         'cfg/abbtype.pxd')

graph_pyx_cpp = custom_target('graph_pyx',
    output : 'graph_pyx.cpp',
    input : ['graph.pyx', pygraph_includes, common_cython_files],
    command : [cython, '-I', bgl_cython_inc, '-I', common_cython_inc, '@INPUT0@', '-o', '@OUTPUT@'] + cython_flags,
)

libgraph = py3_inst.extension_module('graph',
    graph_pyx_cpp, 'graph.cc', 'cfg.cpp',
    dependencies : [py3_inst.dependency(), llvm_dep, boost_dep, common_dep, bgl_dep]
)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with : libgraph,
                               include_directories : graph_inc)

graphdir = meson.current_build_dir()

graph_cython_inc = meson.current_source_dir()
