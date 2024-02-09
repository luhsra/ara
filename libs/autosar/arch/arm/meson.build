arm_autosar_includes = ['-I', meson.current_source_dir()]
arm_autosar_includes += ['-I', meson.current_source_dir() / 'platforms' / 'raspberry']


src_files = [
  'constructors.cc',
  'dispatch.cc',
  'gic.cc',
  'machine.cc',
  'memutil.cc',
  'output.cc',
  'reschedule-ast.cc',
  'startup.cc',
  'syscall.cc',
  'spinlock.cc',
  'bufferedserial.cc',
  'mp.cc',
  'platforms/raspberry/machine_impl.cc',
  'platforms/raspberry/timer.cc',
  'platforms/raspberry/mmu.cc',
  'platforms/raspberry/serial.cc',
  'platforms/raspberry/pmu.cc',
  'irq.S',
  'platforms/raspberry/startup.S'
]

obj_targets = []

foreach src : src_files
  obj_target = custom_target(
    src.underscorify(),
    input: src,
    output: src.underscorify()+'.o',
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

libautosar_arch_pi4 = custom_target('libautosar_arch_pi4',
  input: obj_targets,
  output: 'libautosar_arch_pi4.a',
  command: arm_ar_cmd
)