graph_cython_inc = meson.current_source_dir()

# libgraph
libgraph_dependencies = [py3_inst.dependency(), llvm_dep, boost_dep, graph_tool_dep, common_dep, pyllco_dep, svf_dep]


libgraph = static_library('graph',
                          'graph.cpp',
                          'arguments.cpp',
                          dependencies: libgraph_dependencies)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with: libgraph,
                               include_directories: graph_inc,
                               dependencies: libgraph_dependencies)

# graphdata submodule
graph_data_pyx_cpp = custom_target('graph_data_pyx',
  output: ['graph_data_pyx.cpp'],
  input: files('graph_data.pyx'),
  depend_files: files('graph_data.pxd'),
  command: [cython, '--capi-reexport-cincludes', '@INPUT@', '-o', '@OUTPUT0@'] + cython_flags,
)

graph_data_mod = py3_inst.extension_module('graph_data',
  graph_data_pyx_cpp,
  dependencies: [py3_inst.dependency(), llvm_dep, graph_tool_dep, common_dep, svf_dep, graph_dep]
)
graph_data_dir = meson.current_build_dir()
