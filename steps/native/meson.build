native_step_pyx_cpp = custom_target('native_step_pyx',
  output : ['native_step_pyx.cpp'],
  input : files('native_step.pyx',
                'DetectInteractions.pxd',
                'FreeRTOSinstances.pxd',
                'IntermediateAnalysis.pxd',
                'Validation.pxd',
                'bb_split.pxd',
                'comp_insert.pxd',
                'cstep.pxd',
                'ir_reader.pxd',
                'llvm.pxd',
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
  files('DetectInteractions.cpp',
        'FreeRTOSinstances.cpp',
        'IntermediateAnalysis.cpp',
        'Validation.cpp',
        'bb_split.cpp',
        'comp_insert.cpp',
        'ir_reader.cpp',
        'llvm.cpp',
        'llvm_common.cpp',
        'llvm_dumper.cpp',
        'test/bb_split_test.cpp',
        'test/comp_insert_test.cpp',
        'test/test.cpp'),
  dependencies: [log_dep, py3_inst.dependency(), graph_dep, llvm_dep]
)

stepdir = meson.current_build_dir()
