graph_cython_inc = meson.current_source_dir()

libgraph_dependencies = [py3_inst.dependency(), llvm_dep, boost_dep, graph_tool_dep, common_dep]


libgraph = static_library('graph',
                          'graph.cpp',
                          dependencies: libgraph_dependencies)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with: libgraph,
                               include_directories: graph_inc,
                               dependencies: libgraph_dependencies)
