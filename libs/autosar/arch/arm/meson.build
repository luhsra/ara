arm_autosar_includes = ['-I', meson.current_source_dir()]
arm_autosar_includes += ['-I', meson.current_source_dir() / 'platforms' / 'raspberry']


src_files = [
  'constructors',
  'dispatch',
  'gic',
  'machine',
  'memutil',
  'output',
  'reschedule-ast',
  'startup',
  'syscall',
  'spinlock',
  'bufferedserial',
  'mp',
  'platforms/raspberry/machine_impl',
  'platforms/raspberry/timer',
  'platforms/raspberry/mmu',
  'platforms/raspberry/serial',
  'platforms/raspberry/pmu'
]

as_files = [
  'irq.S',
  'platforms/raspberry/startup.S'
]

obj_targets = []

foreach src : src_files
  obj_target = custom_target(
    src.underscorify(),
    input: src+'.cc',
    output: src.underscorify()+'.cc.o',
    depfile: src.underscorify()+'.dep',
    command: clang_cpp +
      arm_autosar_includes +
      autosar_includes +
      obj_flags +
      clang_flags +
      autosar_pi4_clang_flags
  )
  obj_targets += obj_target
endforeach

arm_gcc = toolchains.get_variable('arm_gcc')
clang_base = libplatform_proj.get_variable('clang_base')

foreach src : as_files
  obj_target = custom_target(
    src.underscorify(),
    input: src,
    output: src.underscorify()+'.o',
    depfile: src.underscorify()+'.dep',
    command: [arm_gcc, clang_base, autosar_pi4_gcc_flags, obj_flags]
  )
  obj_targets += obj_target
endforeach

libautosar_arch_pi4 = custom_target('libautosar_arch_pi4',
  input: obj_targets,
  output: 'libautosar_arch_pi4.a',
  command: arm_ar_cmd
)