librepilot_dir = meson.current_source_dir()
librepilot_cflags = [
'-mthumb',
'-mcpu=cortex-m3',
'--specs=nano.specs',
'-Os',
'-gdwarf-2',
# '-mapcs-frame',
'-fomit-frame-pointer',
'-Wall',
'-Wextra',
'-Wfloat-equal',
'-Wdouble-promotion',
'-Wshadow',
'-fdata-sections',
'-ffunction-sections',
# '-std=gnu99',
'-Wunsuffixed-float-constants',
'-DUSE_INPUT_LPF',
'-DUSE_GIMBAL_LPF',
'-DUSE_GIMBAL_FF',
'-DSTM32F10X',
'-DSTM32F10X_MD',
'-DSTM32F1',
'-DUSE_STDPERIPH_DRIVER',
'-DARM_MATH_CM3',
'-DHSE_VALUE=8000000',
'-DMODULE_ATTITUDE_BUILTIN',
'-DMODULE_STABILIZATION_BUILTIN',
'-DMODULE_ACTUATOR_BUILTIN',
'-DMODULE_RECEIVER_BUILTIN',
'-DMODULE_MANUALCONTROL_BUILTIN',
'-DMODULE_FIRMWAREIAP_BUILTIN',
'-DMODULE_TELEMETRY_BUILTIN',
'-DHAS_CAMERASTAB_MODULE',
'-DHAS_COMUSBBRIDGE_MODULE',
'-DHAS_GPS_MODULE',
'-DHAS_TXPID_MODULE',
'-DHAS_OSDOUTPUT_MODULE',
'-DHAS_UAVOMSPBRIDGE_MODULE',
'-DHAS_UAVOMAVLINKBRIDGE_MODULE',
'-DHAS_ATTITUDE_MODULE',
'-DHAS_STABILIZATION_MODULE',
'-DHAS_ACTUATOR_MODULE',
'-DHAS_RECEIVER_MODULE',
'-DHAS_MANUALCONTROL_MODULE',
'-DHAS_FIRMWAREIAP_MODULE',
'-DHAS_TELEMETRY_MODULE',
'-DUSE_STM32103CB_CC_Rev1',
'-DBOARD_TYPE=0x04',
'-DBOARD_REVISION=0x02',
'-DHW_TYPE=0x01',
'-DBOOTLOADER_VERSION=0x04',
'-DFW_BANK_BASE=0x08003000',
'-DFW_BANK_SIZE=0x0001D000',
'-DFW_DESC_SIZE=0x00000064',
'-DBL_BANK_BASE=0x08000000',
'-DBL_BANK_SIZE=0x00003000',
'-DBL_DESC_SIZE=',
'-mllvm', '-inline-threshold=2',
]


librepilot_includes = [
'-I', join_paths(librepilot_dir, 'flight/pios/common/libraries/FreeRTOS//Source/include'),
'-I', join_paths(librepilot_dir, 'flight/pios/stm32f10x/inc'),
'-I', join_paths(librepilot_dir, 'flight/pios/common/libraries/CMSIS/Include'),
'-I', join_paths(librepilot_dir, 'flight/pios/stm32f10x/libraries/CMSIS/Core/CM3'),
'-I', join_paths(librepilot_dir, 'flight/pios/stm32f10x/libraries/STM32F10x_StdPeriph_Driver/inc'),
'-I', join_paths(librepilot_dir, 'flight/pios/stm32f10x/libraries/STM32_USB-FS-Device_Driver/inc'),
'-I', join_paths(librepilot_dir, 'flight/pios/common/libraries/FreeRTOS//Source/portable/GCC/ARM_CM3'),
'-I', join_paths(librepilot_dir, 'flight/pios'),
'-I', join_paths(librepilot_dir, 'flight/pios/inc'),
'-I', join_paths(librepilot_dir, 'flight/targets/boards/coptercontrol/firmware/..'),
'-I', join_paths(librepilot_dir, 'flight/targets/boards/coptercontrol'),
'-I', join_paths(librepilot_dir, 'flight/libraries/inc'),
'-I', join_paths(librepilot_dir, 'flight/pios/common'),
'-I', join_paths(librepilot_dir, 'flight/targets/boards/coptercontrol/firmware'),
'-I', join_paths(librepilot_dir, 'flight/targets/boards/coptercontrol/firmware/inc'),
'-I', join_paths(librepilot_dir, 'flight/libraries/math'),
'-I', join_paths(librepilot_dir, 'flight/libraries/pid'),
'-I', join_paths(librepilot_dir, 'flight/uavobjects/inc'),
'-I', join_paths(librepilot_dir, 'flight/uavtalk/inc'),
'-I', join_paths(librepilot_dir, 'build/firmware/uavobjects'),
'-I', join_paths(librepilot_dir, 'flight/libraries/mavlink/v1.0/common'),
'-I', join_paths(librepilot_dir, 'flight/modules/CameraStab/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/ComUsbBridge/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/GPS/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/TxPID/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/Osd/osdoutput/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/UAVOMSPBridge/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/UAVOMavlinkBridge/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/Attitude/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/Stabilization/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/Actuator/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/Receiver/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/ManualControl/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/FirmwareIAP/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/Telemetry/inc'),
'-I', join_paths(librepilot_dir, 'flight/modules/System/inc'),
] + freertos_includes + libsra_includes


librepilot_ldflags = [
  '--specs=nano.specs',
  '-T' + meson.current_source_dir() / 'flight/pios/stm32f10x//link_STM32103CB_CC_Rev1_memory.ld',
  '-T' + meson.current_source_dir() /'flight/pios/stm32f10x//link_STM32103CB_CC_Rev1_sections.ld',
  # '-Wl,--fatal-warnings',
  '-Wl,--sort-common',
  '-Wl,--sort-section=alignment',
  '-lm',
  # '-lc_nano',
  '-lgcc',
  '-Wl,-static',
  '-nostartfiles',
  '-Os',
]

librepilot_targets = []
librepilot_mock_targets = []

librepilot_compile = generator(clang,
                              output: '@BASENAME@.ll',
                              depfile: '@BASENAME@_dep',
                              arguments: clang_base +
                                         [c_std] +
                                         librepilot_includes +
                                         ir_flags +
                                         librepilot_cflags +
                                         clang_flags
                             )

librepilot_mock_compile = generator(clang,
                                output: '@BASENAME@.ll',
                                depfile: '@BASENAME@_dep',
                                arguments: clang_base +
                                           [c_std] +
                                           librepilot_includes +
                                           ir_flags +
                                           librepilot_cflags +
                                           ['-DARA_MOCK'] +
                                           clang_flags
                               )

subdir('build')
subdir('flight')

librepilot_ll = custom_target('librepilot_app.ll',
                              input: librepilot_targets,
                              output: 'librepilot_app.ll',
                              command: llvm_link_cmd,
                              )
librepilot_mock_ll = custom_target('librepilot_mock_app.ll',
                                            input: librepilot_mock_targets,
                                            output: 'librepilot_mock.ll',
                                            command: llvm_link_cmd,
                                  )
librepilot_application = librepilot_mock_ll



named_elf_targets = []
elf_targets = []
named_plain_elf_targets = []
named_lto_elf_targets = []
foreach application_prefix: ['librepilot', 'librepilot_mock']
  foreach t : ara_gen_freertos_targets
    application_ll = get_variable(application_prefix + '_ll')
    name_prefix = application_prefix + '-' + t
    ara_target = custom_target(name_prefix + '-os',
                               input: application_ll,
                               depfile: name_prefix+ '-os.cc.dep',
                               output: [name_prefix + '-os.cc',
                                        name_prefix + '-os.cc.startup.s',
                                        name_prefix + '-modifiedapp.ll'],
                               command: get_variable('ara_gen_cmd_' + t)
                              )
    os_target = [ara_target[0], ara_target[1]]
    app_aramodified_ll = ara_target[2]

    lib_freertos_ll_targets = []
    foreach src_file : get_variable('libfreertos_src_files_' + t)
      lib_freertos_ll_targets += librepilot_compile.process(src_file)
    endforeach

    o_target = custom_target(name_prefix + '.o',
                             input : app_aramodified_ll,
                             output : name_prefix + '.ll.o',
                             command : llc_cmd)

    os_ll_target = custom_target(name_prefix + '-os.cc.ll',
                                 input : os_target,
                                 output : name_prefix + '-os.cc.ll',
                                 depfile : name_prefix + '-os.cc.ll.dep',
                                 command : clang_cpp +
                                           librepilot_includes +
                                           ir_flags +
                                           clang_flags)

    app_os = custom_target(name_prefix + '-app_os.ll',
                           input: [app_aramodified_ll, os_ll_target,
                                   lib_freertos_ll_targets],
                           output: name_prefix + '-os_app.ll',
                           command: llvm_link_cmd)

    lto_app_os = custom_target(name_prefix + '-lto_app_os.ll',
                               input: app_os,
                               output: name_prefix + '-lto_os_app.ll',
                               command: llvm_opt_cmd + ['-Os'])

    lto_o = custom_target(name_prefix + '-lto_app_os.o',
                          input: lto_app_os,
                          output: name_prefix + '-lto_os_app.ll.o',
                          command: llc_cmd)

    lto_elf = custom_target(name_prefix + '.lto.elf',
                            input: [lto_o,
                                    # os_target[1], # startup.s
                                    files('flight/pios/stm32f10x/startup_stm32f10x_MD_CC.S'),
                                    libsra_ar,
                                   ],
                            output: name_prefix + '.lto.elf',
                            depfile: name_prefix + '.lto.elf.dep',
                            command: clang_cpp +
                                     librepilot_includes +
                                     ld_flags +
                                     librepilot_ldflags +
                                     clang_flags,
                            depend_files: [files(meson.current_source_dir() / 'flight/pios/stm32f10x//link_STM32103CB_CC_Rev1_memory.ld',
                                                 meson.current_source_dir() /'flight/pios/stm32f10x//link_STM32103CB_CC_Rev1_sections.ld',
                                                )
                                          ],
                           )

    elf_target = custom_target(name_prefix + '.elf',
                               input: [o_target,
                                       os_target[0],
                                       files('flight/pios/stm32f10x/startup_stm32f10x_MD_CC.S'),
                                       lib_freertos_ll_targets,
                                       libsra_ar,
                                      ],
                               output: name_prefix + '.elf',
                               depfile: name_prefix + '.elf.dep',
                               command: clang_cpp +
                                        librepilot_includes +
                                        ld_flags +
                                        librepilot_ldflags +
                                        clang_flags,
                               depend_files: [files(meson.current_source_dir() / 'flight/pios/stm32f10x/link_STM32103CB_CC_Rev1_memory.ld',
                                                    meson.current_source_dir() / 'flight/pios/stm32f10x/link_STM32103CB_CC_Rev1_sections.ld',
                                                   )
                                             ],
                              )

    bin_target = custom_target(name_prefix + '.bin',
                               input: [elf_target],
                               output: name_prefix + '.bin',
                               command: objcopy_cmd)

    lto_bin_target = custom_target(name_prefix + '.lto.bin',
                                   input: [lto_elf],
                                   output: name_prefix + '.lto.bin',
                                   command: objcopy_cmd)

    run_target('flash_' + name_prefix, command: ['st-flash', 'write', bin_target, '0x8000000'])
    run_target('flash_' + name_prefix + '.lto', command: ['st-flash', 'write', lto_bin_target, '0x8000000'])
    run_target('size_' + name_prefix, command: [size, elf_target])
    run_target('size_' + name_prefix + '.lto', command: [size, lto_elf])
    run_target('run_gdb_hw_' + name_prefix, command: [gdb_hw_script, elf_target])
    run_target('run_qemu_' + name_prefix, command: [qemu_cmd, elf_target])
    run_target('run_gdb_qemu_' + name_prefix, command: [gdb_qemu_cmd, elf_target])
    run_target('run_qemu_' + name_prefix + '-lto', command: [qemu_cmd, lto_elf])
    run_target('run_gdb_qemu_' + name_prefix + '-lto', command: [gdb_qemu_cmd, lto_elf])
    elf_targets += elf_target
    elf_targets += lto_elf
    named_elf_targets += [t, elf_target]
    named_elf_targets += [t+'.lto', lto_elf]
    named_plain_elf_targets += [t, elf_target]
    named_lto_elf_targets += [t+'.lto', lto_elf]

    if get_option('enable_librepilot_tests')
      if t in ['instances_full_static', 'instances_full_initialized', 'vanilla']
        test_elf = 'nop'
      else
        test_elf = elf_target
      endif
      test('run_qemu_' + name_prefix,
           py3_inst,
           args: [qemu_test_runner,
                  qemu_cmd,
                  'librepilot',
                  test_elf,
                 ],
           env: [python_path],
           workdir: meson.current_source_dir(),
           suite: 'librepilot',
           is_parallel: false,
          )
    endif


  endforeach

  run_target('compare_nm-' + application_prefix, command: [compare_nm, nm.path(), named_elf_targets])
  run_target('compare_nm-' + application_prefix + '-plain', command: [compare_nm, nm.path(), named_plain_elf_targets])
  run_target('compare_nm-' + application_prefix + '-lto', command: [compare_nm, nm.path(), named_lto_elf_targets])
  run_target('compare_size-' + application_prefix, command: [size, elf_targets])
  run_target('compare_time-' + application_prefix, command: [compare_time, meson.build_root(), 'librepilot'], depends: elf_targets)
  # custom_target('analyze-librepilot',
  #               command: [files('LibrepilotExperiment.py'), '-d', meson.current_build_dir(),
  #                         '-s',
  #                         '--run-dir', meson.build_root()],
  #               output: ['librepilot_result.dref',
  #                        'librepilot_raw.dref'],
  #               console: true,
  #               depends: elf_targets)
endforeach
