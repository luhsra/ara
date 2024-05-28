riscv_autosar_includes = ['-I', meson.current_source_dir()]
# riscv_autosar_includes += ['-I', meson.current_source_dir() / 'platforms' / 'r5']
# Wenn maschinenabhängige Dateien hinzugefügt werden, müssen sie hier eingebunden werden

src_files = [
  'constructors.cc',
  'dispatch.cc',
  'interrupt.cc',
  'mp.cc',
  'output.cc',
  'serial.cc',
  'startup.cc',
  'startup.S',
  #'timer.cc'
]

obj_targets = []

foreach src : src_files
    obj_target = custom_target(
        src,
        input: src,
        output: src +'.o',
        depfile: src +'.dep',
        command: clang_cpp +
                riscv_autosar_includes +
                autosar_includes +
                obj_flags +
                autosar_riscv_clang_flags +
                clang_flags)
    obj_targets += obj_target
endforeach

libautosar_arch_riscv = custom_target('libautosar_arch_riscv',
                                      input: obj_targets,
                                      output: 'libautosar_arch_riscv.a',
                                      command: ar_cmd)

autosar_riscv_linkerscript = meson.current_source_dir() / 'linker.ld'