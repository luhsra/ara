posix_autosar_includes = ['-I', meson.current_source_dir()]

src_files = [
  'dispatch',
  'irq',
  'itimer',
  'mp',
  'output',
  'signalinfo',
  'startup',
  'terminal',
  'spinlock'
]

obj_targets = []

foreach src : src_files
    obj_target = custom_target(
        src,
        input: src+'.cc',
        output: src+'.cc.o',
        depfile: src+'.dep',
        command: clang_cpp +
                posix_autosar_includes +
                autosar_includes +
                autosar_posix_ld_flags +
                obj_flags +
                autosar_posix_clang_flags +
                clang_flags)
    obj_targets += obj_target
endforeach

libautosar_arch_posix = custom_target('libautosar_arch_posix',
                                      input: obj_targets,
                                      output: 'libautosar_arch_posix.a',
                                      command: ar_cmd)