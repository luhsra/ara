libs_includes += ['-I', meson.current_source_dir()]
autosar_includes += ['-I', meson.current_source_dir()]

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
                autosar_includes +
                ld_flags +
                obj_flags +
                clang_flags)
    obj_targets += obj_target
endforeach

libautosar_arch = custom_target('libautosar_arch',
                                    input: obj_targets,
                                    output: 'libautosar_arch.a',
                                    command: ar_cmd)