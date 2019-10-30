graph_cython_inc = meson.current_source_dir()

llvm_wrapper_includes = files('llvm_wrapper.pxd', 'llvm.pxd')

llvm_wrapper_cpp = custom_target('llvm_wrapper_pyx',
    output: 'llvm_wrapper_pyx.cpp',
    input: ['llvm_wrapper.pyx', llvm_wrapper_includes],
    command : [cython, '-I', graph_cython_inc, '@INPUT0@', '-o', '@OUTPUT@'] + cython_flags,
)

llvm_wrapper = py3_inst.extension_module('llvm_wrapper',
    llvm_wrapper_cpp,
    dependencies : [py3_inst.dependency(), llvm_dep]
)

llvm_wrapper_inc = include_directories('.')
llvm_wrapper_dep = declare_dependency(link_with : llvm_wrapper,
                                      include_directories : llvm_wrapper_inc)

libgraph_dependencies = [py3_inst.dependency(), llvm_dep, boost_dep, graph_tool_dep, common_dep]


libgraph = static_library('graph',
                          'graph.cpp',
                          dependencies: libgraph_dependencies)

graph_inc = include_directories('.')
graph_dep = declare_dependency(link_with: libgraph,
                               include_directories: graph_inc,
                               dependencies: libgraph_dependencies)

llvm_wrapper_dir = meson.current_build_dir()
