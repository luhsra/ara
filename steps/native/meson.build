llvm_dep = dependency('llvm', version : '>=6.0')

native_step_pyx_cpp = custom_target('native_step_pyx',
  output : 'native_step_pyx.cpp',
  input : 'native_step.pyx',
  command : [cython, '-I', '../subprojects/libgraph', '@INPUT@', '--cplus', '-3', '-o', '@OUTPUT@'],
)

plib = py3_inst.extension_module('native_step',
  native_step_pyx_cpp,
  'llvm.cpp',
  'test.cpp',
  dependencies : [py3_inst.dependency(), libgraph, llvm_dep]
)

passdir = meson.current_build_dir()
