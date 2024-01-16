libs_includes += ['-I', meson.current_source_dir()]
autosar_includes += ['-I', meson.current_source_dir()]


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
  'mp'
]

as_files = [
  'irq.S'
]

if get_option('platform') == 'zedboard'
  platform_path = 'platforms/zedboard/'
  autosar_includes += ['-I', meson.current_source_dir() / platform_path ]

  platform_files = [
    'machine_impl',
    'timer',
    'serial'
  ]

  as_platform_files = [
    'startup.S',
    'translation_table.S'
  ]

elif get_option('platform') == 'raspi_32'
  platform_path = 'platforms/raspberry/'
  autosar_includes += ['-I', meson.current_source_dir() / platform_path ]

  platform_files = [
    'machine_impl',
    'timer',
    'mmu',
    'pmu',
    'serial'
  ]

  as_platform_files = [
    'startup.S'
  ]
endif

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

foreach src : as_files
    obj_target = custom_target(
        src,
        input: src,
        output: src+'.o',
        depfile: src+'.dep',
        command: [system_gcc, clang_base, arm_gcc_flags, obj_flags])
    obj_targets += obj_target
endforeach

foreach src : platform_files
    obj_target = custom_target(
        src,
        input: platform_path / src+'.cc',
        output: src+'.cc.o',
        depfile: src+'.dep',
        command: clang_cpp +
                autosar_includes +
                obj_flags +
                clang_flags)
    obj_targets += obj_target
endforeach

foreach src : as_platform_files
    obj_target = custom_target(
        src,
        input: platform_path / src,
        output: src+'.o',
        depfile: src+'.dep',
        command: [system_gcc, clang_base, arm_gcc_flags, obj_flags])
    obj_targets += obj_target
endforeach

libautosar_arch = custom_target('libautosar_arch',
                                    input: obj_targets,
                                    output: 'libautosar_arch.a',
                                    command: ar_cmd)