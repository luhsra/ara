autosar_includes += ['-I', meson.current_source_dir()]

src_files = [
    'test',
]

obj_targets = []

foreach src : src_files
    obj_target = custom_target(
        src + '.cc',
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

libautosar_test = custom_target('libautosar_test',
                                    input: obj_targets,
                                    output: 'libautosar_test.a',
                                    command: ar_cmd)