native_step_pyx_cpp = custom_target('native_step_pyx',
  output : ['native_step_pyx.cpp'],
  input : files('native_step.pyx',
                'option.pxd',
                'detect_interactions.pxd',
                'freertos_instances.pxd',
                'intermediate_analysis.pxd',
                'validation.pxd',
                'bb_split.pxd',
                'cdummy.pxd',
                'comp_insert.pxd',
                'cstep.pxd',
                'fn_single_exit.pxd',
                'ir_reader.pxd',
                'llvm.pxd',
                'llvm_basic_optimization.pxd',
                'llvm_map.pxd',
                'test.pxd',
                'warning.pxd'),
  command : [cython, '-I', graph_cython_inc, '@INPUT0@', '-o', '@OUTPUT@'] + cython_flags,
)

py_logging_pyx_cpp = custom_target('py_logging_pyx',
  output : ['py_logging.cpp', 'py_logging.h'],
  input : files('py_logging.pyx'),
  command : [cython, '@INPUT@', '-o', '@OUTPUT0@'] + cython_flags,
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
        'detect_interactions.cpp',
        'freertos_instances.cpp',
        'intermediate_analysis.cpp',
        'validation.cpp',
        'bb_split.cpp',
        'cdummy.cpp',
        'comp_insert.cpp',
        'fn_single_exit.cpp',
        'ir_reader.cpp',
        'llvm.cpp',
        'llvm_basic_optimization.cpp',
        'llvm_common.cpp',
        'llvm_dumper.cpp',
        'llvm_map.cpp',
        'test/bb_split_test.cpp',
        'test/comp_insert_test.cpp',
        'test/fn_single_exit_test.cpp',
        'test/llvm_map_test.cpp',
        'test/test.cpp'),
  dependencies: [log_dep, py3_inst.dependency(), graph_dep, llvm_dep]
)

stepdir = meson.current_build_dir()
