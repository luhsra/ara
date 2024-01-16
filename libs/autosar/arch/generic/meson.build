autosar_includes += ['-I', meson.current_source_dir()]

src_files = [
    'startup',
    'timing-arch',
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
                obj_flags +
                clang_flags)
    obj_targets += obj_target
endforeach

libautosar_generic = custom_target('libautosar_generic',
                                    input: obj_targets,
                                    output: 'libautosar_generic.a',
                                    command: ar_cmd)