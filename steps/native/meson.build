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
native_step_pyx_gen = custom_target('native_step_pyx',
  output : ['native_step_pyx.cpp', 'native_step_pyx.h'],
  input : [files('native_step.pyx',
                 'option.pxd',
                 'bb_split.pxd',
                 'cdummy.pxd',
                 'comp_insert.pxd',
                 'cstep.pxd',
                 'fake_entry_point.pxd',
                 'fn_single_exit.pxd',
                 'icfg.pxd',
                 'ir_reader.pxd',
                 'ir_writer.pxd',
                 'llvm_map.pxd',
                 'llvm_optimization.pxd',
                 'replace_syscalls_create.pxd',
                 'replace_syscalls_create.pxi',
                 'value_analysis_core.pxd',
                 'test.pxd') + common_cython_files],
  command : [cython, '-I', graph_cython_inc, '-I', common_cython_inc, '-I', pyllco_cython_inc, '@INPUT0@', '-o', '@OUTPUT0@'] + cython_flags,
)

native_step_pyx_cpp = native_step_pyx_gen[0]
native_step_pyx_h   = native_step_pyx_gen[1]

plib = py3_inst.extension_module('native_step',
  native_step_pyx_cpp,
  files('option.cpp',
        'bb_split.cpp',
        'cdummy.cpp',
        'comp_insert.cpp',
        'fake_entry_point.cpp',
        'fn_single_exit.cpp',
        'icfg.cpp',
        'ir_reader.cpp',
        'ir_writer.cpp',
        'llvm_map.cpp',
        'llvm_optimization.cpp',
        'replace_syscalls_create.cpp',
        'step_manager.cpp',
        'value_analysis_core.cpp',
        'value_analyzer.cpp',
        'test/bb_split_test.cpp',
        'test/comp_insert_test.cpp',
        'test/cfg_optimize_test.cpp',
        'test/fn_single_exit_test.cpp',
        'test/llvm_map_test.cpp',
        'test/test.cpp'),
  cpp_pch: 'pch/steps_pch.h',
  dependencies: [log_dep, py3_inst.dependency(), llvm_dep, graph_dep, common_dep, pyllco_dep]
)

step_dir = meson.current_build_dir()
