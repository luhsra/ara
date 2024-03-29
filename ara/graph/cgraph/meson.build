# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Jan Neugebauer
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

graph_cython_inc = meson.current_source_dir()

graph_inc = include_directories('.')

# graphdata submodule
graph_data_pyx = custom_target('graph_data_pyx',
  output: ['graph_data_pyx.cpp', 'graph_data_pyx.h'],
  input: files('graph_data.pyx'),
  depend_files: files('cgraph.pxd', 'graph_data.pxd', 'carguments.pxd', 'os.pxd', 'cy_helper.pxd'),
  command: [cython, '-I', graph_cython_inc, '-I', common_cython_inc, '-I', pyllco_cython_inc, '@INPUT@', '-o', '@OUTPUT0@'] + cython_flags,
)
graph_data_pyx_header = graph_data_pyx[1]
graph_data_pyx_cpp = graph_data_pyx[0]

graph_data_mod = py3_inst.extension_module('graph_data',
  graph_data_pyx_cpp,
  'graph.cpp',
  'arguments.cpp',
  'callpath.cpp',
  'mix.cpp',
  'os.cpp',
  gnu_symbol_visibility: 'default',
  override_options: 'b_lundef=false',
  dependencies: [py3_inst.dependency(), llvm_dep, boost_dep, graph_tool_dep, common_dep, pyllco_dep, svf_dep]
)
graph_data_dir = meson.current_build_dir()

graph_dep = declare_dependency(
  include_directories: graph_inc,
  sources: graph_data_pyx_header
)
