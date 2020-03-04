graph_cython_inc = meson.current_source_dir()

# llvmdata submodule
llvm_data_pyx_cpp = custom_target('llvm_data_pyx',
  output: ['llvm_data_pyx.cpp'],
  input: files('llvm_data.pyx'),
  depend_files: files('llvm_data.pxd'),
  command: [cython, '--capi-reexport-cincludes', '@INPUT@', '-o', '@OUTPUT0@'] + cython_flags,
)

llvm_data_mod = py3_inst.extension_module('llvm_data',
  llvm_data_pyx_cpp,
  dependencies: [py3_inst.dependency(), llvm_dep]
)
llvm_data_dir = meson.current_build_dir()


libgraph_dependencies = [py3_inst.dependency(), llvm_dep, boost_dep, graph_tool_dep, common_dep, pyllco_dep]


libgraph = static_library('graph',
                          'graph.cpp',
                          'arguments.cpp',
                          dependencies: libgraph_dependencies)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with: libgraph,
                               include_directories: graph_inc,
                               dependencies: libgraph_dependencies)
