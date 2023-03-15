# SPDX-FileCopyrightText: 2019 Benedikt Steinmeier
# SPDX-FileCopyrightText: 2019 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2019 Manuel Breiden
# SPDX-FileCopyrightText: 2020 Kenny Albes
# SPDX-FileCopyrightText: 2020 Manuel Breiden
# SPDX-FileCopyrightText: 2020 Yannick Loeck
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

# logging submodule
py_logging_pyx_cpp = custom_target('py_logging_pyx',
  output : ['py_logging.cpp', 'py_logging.h'],
  input : files('py_logging.pyx'),
  command : [cython, '--capi-reexport-cincludes', '@INPUT@', '-o', '@OUTPUT0@'] + cython_flags,
)
py_logging_header = py_logging_pyx_cpp[1]

log_bridge = py3_inst.extension_module('py_logging',
  py_logging_pyx_cpp,
  gnu_symbol_visibility: 'default',
  dependencies: py3_inst.dependency()
)

log_bridge_incl = include_directories('.')

# Attention: When using this dependency, you must also
# somehow trigger the compilation of log_bridge.
log_dep = declare_dependency(
  include_directories: log_bridge_incl,
  sources: py_logging_header)

# steps
step_dir = meson.current_build_dir()

conf_data = configuration_data()
if get_option('enable_step_tests')
  test_pxd = ['test.pxd']
  conf_data.set('step_tests', 'True')
else
  test_pxd = []
  conf_data.set('step_tests', 'False')
endif
conf_file = configure_file(input: 'project_config.pxi.in',
  output: 'project_config.pxi',
  configuration: conf_data)

step_pyx_gen = custom_target('step_pyx',
  output : ['step_pyx.cpp', 'step_pyx.h'],
  input : [files('step.pyx',
                 'option.pxd',
                 'cy_helper.pxd',
                 'cstep.pxd',
                 'replace_syscalls_create.pxd',
                 'value_analyzer.pxd',
                 'value_analyzer.pxi',
                 'tracer_api.pxi') + test_pxd + common_cython_files],
  command : [cython, '-I', graph_cython_inc, '-I', common_cython_inc, '-I', pyllco_cython_inc, '-I', step_dir, '@INPUT0@', '-o', '@OUTPUT0@'] + cython_flags,
  depend_files: [conf_file],
)

step_pyx_cpp = step_pyx_gen[0]
step_pyx_h   = step_pyx_gen[1]

if get_option('enable_step_tests')
  test_sources = files('test/bb_split_test.cpp',
                       'test/comp_insert_test.cpp',
                       'test/cfg_optimize_test.cpp',
                       'test/fn_single_exit_test.cpp',
                       'test/llvm_map_test.cpp',
                       'test/posix_clang_global_test.cpp',
                       'test/test.cpp')
else
  test_sources = []
endif

step_mod = py3_inst.extension_module('step',
  step_pyx_cpp,
  files('step.cpp',
        'option.cpp',
        'step_manager.cpp',
        # C++ steps from here on (sorted alphabetically)
        'bb_split.cpp',
        'bb_timings.cpp',
        'callgraph.cpp',
        'cdummy.cpp',
        'comp_insert.cpp',
        'fake_entry_point.cpp',
        'fn_single_exit.cpp',
        'ir_reader.cpp',
        'ir_writer.cpp',
        'llvm_map.cpp',
        'llvm_optimization.cpp',
        'load_freertos_config.cpp',
        'posix_static.cpp',
        'remove_sysfunc_body.cpp',
        'replace_syscalls_create.cpp',
        'resolve_function_pointer.cpp',
        'svf_analyses.cpp',
        'svf_transformation.cpp',
        'zephyr_static.cpp',
        # additional C++ entities
        'value_analyzer.cpp',
        'py_util.cpp',
        'tracer_api.cpp') + test_sources,
  gnu_symbol_visibility: 'default',
  override_options: 'b_lundef=false',
  cpp_pch: 'pch/steps_pch.h',
  link_depends: [log_bridge, graph_data_mod],
  dependencies: [log_dep, py3_inst.dependency(), llvm_dep, graph_tool_dep, graph_dep, common_dep, pyllco_dep, svf_dep]
)

