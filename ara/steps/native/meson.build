# logging submodule
py_logging_pyx_cpp = custom_target('py_logging_pyx',
  output : ['py_logging.cpp', 'py_logging.h'],
  input : files('py_logging.pyx'),
  command : [cython, '--capi-reexport-cincludes', '@INPUT@', '-o', '@OUTPUT0@'] + cython_flags,
)
py_logging_header = py_logging_pyx_cpp[1]

log_bridge = py3_inst.extension_module('py_logging',
  py_logging_pyx_cpp,
  dependencies: py3_inst.dependency()
)

log_bridge_incl = include_directories('.')

log_dep = declare_dependency(
  include_directories: log_bridge_incl,
  link_with: log_bridge,
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
                 'backported_utility.pxd',
                 'replace_syscalls_create.pxd',
                 'replace_syscalls_create.pxi') + test_pxd + common_cython_files],
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
                       'test/test.cpp')
else
  test_sources = []
endif

step_mod = py3_inst.extension_module('step',
  step_pyx_cpp,
  files('step.cpp',
        'option.cpp',
        'step_manager.cpp',
        'bb_split.cpp',
        'cdummy.cpp',
        'comp_insert.cpp',
        'fake_entry_point.cpp',
        'fn_single_exit.cpp',
        'callgraph.cpp',
        'ir_reader.cpp',
        'ir_writer.cpp',
        'llvm_map.cpp',
        'llvm_optimization.cpp',
        'load_freertos_config.cpp',
        'replace_syscalls_create.cpp',
        'resolve_function_pointer.cpp',
        'svf_analyses.cpp',
        'svf_transformation.cpp',
        'value_analysis.cpp') + test_sources,
  cpp_pch: 'pch/steps_pch.h',
  dependencies: [log_dep, py3_inst.dependency(), llvm_dep, graph_tool_dep, graph_dep, common_dep, pyllco_dep, svf_dep, cudd_dep]
)

