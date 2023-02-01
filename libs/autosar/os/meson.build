autosar_includes += ['-I', meson.current_source_dir()]

src_files = [
    'counter',
    'helper',
    'isr',
    'timing',
    'ipi',
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

libautosar_os = custom_target('libautosar_os',
                                    input: obj_targets,
                                    output: 'libautosar_os.a',
                                    command: ar_cmd)