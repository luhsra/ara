native_step_pyx_cpp = custom_target('native_step_pyx',
  output : ['native_step_pyx.cpp'],
  input : [files('native_step.pyx',
                 'option.pxd',
                 'agressive_dce.pxd',
                 'bb_split.pxd',
                 'cdummy.pxd',
                 'comp_insert.pxd',
                 'const_prop.pxd',
                 'dead_code_elimination.pxd',
                 'cstep.pxd',
                 'fn_single_exit.pxd',
                 'icfg.pxd',
                 'ir_reader.pxd',
                 'llvm_basic_optimization.pxd',
                 'llvm_map.pxd',
                 'mem2reg.pxd',
                 'sparse_cond_const_prop.pxd',
                 'value_analysis.pxd',
                 'test.pxd') + common_cython_files],
  command : [cython, '-I', graph_cython_inc, '-I', common_cython_inc, '@INPUT0@', '-o', '@OUTPUT@'] + cython_flags,
)

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

plib = py3_inst.extension_module('native_step',
  native_step_pyx_cpp,
  files('option.cpp',
        'agressive_dce.cpp',
        'bb_split.cpp',
        'cdummy.cpp',
        'comp_insert.cpp',
        'const_prop.cpp',
        'dead_code_elimination.cpp',
        'fn_single_exit.cpp',
        'icfg.cpp',
        'ir_reader.cpp',
        'llvm_basic_optimization.cpp',
        'llvm_map.cpp',
        'mem2reg.cpp',
        'reassociate.cpp',
        'sparse_cond_const_prop.cpp',
        'value_analysis.cpp',
        'value_analyzer.cpp',
        'test/bb_split_test.cpp',
        'test/comp_insert_test.cpp',
        'test/fn_single_exit_test.cpp',
        'test/llvm_map_test.cpp',
        'test/test.cpp'),
  cpp_pch: 'pch/steps_pch.h',
  dependencies: [log_dep, py3_inst.dependency(), llvm_dep, graph_dep, common_dep]
)

stepdir = meson.current_build_dir()
