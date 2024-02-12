autosar_includes += ['-I', meson.current_source_dir()]

src_files = [
    'startup',
]

if posix_enabled
    obj_targets = []

    foreach src : src_files
        obj_target = custom_target(
            src+'_posix',
            input: src+'.cc',
            output: src+'.cc.posix.o',
            depfile: src+'.posix.dep',
            command: clang_cpp +
                    posix_autosar_includes +
                    autosar_includes +
                    obj_flags +
                    autosar_posix_clang_flags +
                    clang_flags)
        obj_targets += obj_target
    endforeach

    libautosar_generic_posix = custom_target('libautosar_generic_posix',
                                        input: obj_targets,
                                        output: 'libautosar_generic_posix.a',
                                        command: posix_ar_cmd)
endif

if arm_enabled
    obj_targets = []

    foreach src : src_files
        obj_target = custom_target(
            src+'_pi4',
            input: src+'.cc',
            output: src+'.cc.pi4.o',
            depfile: src+'.pi4.dep',
            command: clang_cpp +
                    arm_autosar_includes +
                    autosar_includes +
                    obj_flags +
                    autosar_pi4_clang_flags +
                    clang_flags)
        obj_targets += obj_target
    endforeach

    libautosar_generic_pi4 = custom_target('libautosar_generic_pi4',
                                        input: obj_targets,
                                        output: 'libautosar_generic_pi4.a',
                                        command: arm_ar_cmd)
endif