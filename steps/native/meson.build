native_step_pyx_cpp = custom_target('native_step_pyx',
  output : ['native_step_pyx.cpp'],
  input : files('native_step.pyx'),
  command : [cython, '-I', graph_cython_inc, '@INPUT@', '-o', '@OUTPUT@'] + cython_flags,
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
  files('FreeRTOSinstances.cpp',
        'DetectInteractions.cpp',
        'Validation.cpp',
        'IntermediateAnalysis.cpp',
        'llvm.cpp',
        'llvm_dumper.cpp',
        'llvm_common.cpp',
        'test.cpp'),
  dependencies: [log_dep, py3_inst.dependency(), graph_dep, llvm_dep]
)

stepdir = meson.current_build_dir()
