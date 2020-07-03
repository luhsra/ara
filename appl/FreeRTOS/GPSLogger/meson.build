gpslogger_dir = meson.current_source_dir()
gpslogger_cflags = [
    '-DconfigINCLUDE_ALL_DECLS=1',
    '-DMCU_STM32F103RB',
    '-DSTM32F1',
    '-DSTM32F103RB',
    '-DSTM32F103xB',
    '-DARDUINO=10801',
    '-DF_CPU=72000000L',
    '-DUSE_USB_COMPOSITE',
    '-Wno-deprecated-register',
    '-Wno-unused',
    '-Wno-typedef-redefinition',
    '-DENABLE_ARDUINO_FEATURES=0',
    '-ffast-math',
]


gpslogger_includes = [
    '-I', join_paths([gpslogger_dir, 'Src/']),
    '-I', join_paths([gpslogger_dir, 'Libs/FreeRTOS']),
    '-I', join_paths([gpslogger_dir, 'Libs/arduino']),
    '-I', join_paths([gpslogger_dir, 'Libs/arduino/stm32']),
    '-I', join_paths([gpslogger_dir, 'Libs/NeoGPS']),
    '-I', join_paths([gpslogger_dir, 'Libs/AdafruitGFX']),
    '-I', join_paths([gpslogger_dir, 'Libs/Adafruit_SSD1306']),
    '-I', join_paths([gpslogger_dir, 'Libs/USB']),
    '-I', join_paths([gpslogger_dir, 'Libs/USB/Core']),
    '-I', join_paths([gpslogger_dir, 'Libs/USB/CDC']),
    '-I', join_paths([gpslogger_dir, 'Libs/USB/MSC']),
    '-I', join_paths([gpslogger_dir, 'Libs/USB/MSC_CDC']),
    '-I', join_paths([gpslogger_dir, 'Libs/STM32generic/']),
    '-I', join_paths([gpslogger_dir, 'Libs/STM32generic/variants/NUCLEO_F103RB']),
    '-I', join_paths([gpslogger_dir, 'Libs/STM32generic/system/CMSIS']),
    '-I', join_paths([gpslogger_dir, 'Libs/STM32generic/system/STM32F1/HAL_Inc']),
    '-I', join_paths([gpslogger_dir, 'Libs/STM32generic/system/STM32F1/CMSIS_Inc']),
    '-I', join_paths([gpslogger_dir, 'Libs/STM32generic/libraries/SPI/src']),
    '-I', join_paths([gpslogger_dir, 'Libs/SdFat']),
] + freertos_includes + libsra_includes


gpslogger_ldflags = [
    '-lm',
    '-lgcc',
    ]

gpslogger_targets = []

gpslogger_compile = generator(clang,
                              output: '@BASENAME@.ll',
                              depfile: '@BASENAME@_dep',
                              arguments: clang_base +
                                         [c_std] +
                                         gpslogger_includes +
                                         ir_flags +
                                         gpslogger_cflags +
                                         clang_flags
                             )

gpslogger_compilepp = generator(clang,
                                output: '@BASENAME@.ll',
                                depfile: '@BASENAME@_dep',
                                arguments: clang_base +
                                           [cxx_std] +
                                           gpslogger_includes +
                                           ir_flags +
                                           gpslogger_cflags +
                                           clang_flags
                               )

subdir('Libs')

src_files = [
    'Src/8x12Font',
    'Src/BoardInit',
    'Src/SDThread',
    'Src/SerialDebugLogger',
    'Src/IdleThread',
    'Src/LEDThread',
    'Src/ButtonsThread',
    'Src/PrintUtils',
    'Src/SdFatSPIDriver',
    'Src/Screens/Screen',
    'Src/Screens/AltitudeScreen',
    'Src/Screens/CurrentPositionScreen',
    'Src/Screens/CurrentTimeScreen',
    'Src/Screens/DebugScreen',
    'Src/Screens/MemDumpScreen',
    'Src/Screens/OdometerScreen',
    'Src/Screens/OdometerActionScreen',
    'Src/Screens/ParentScreen',
    'Src/Screens/SatellitesScreen',
    'Src/Screens/SelectorScreen',
    'Src/Screens/SettingsGroupScreen',
    'Src/Screens/TimeZoneScreen',
    'Src/Screens/ScreenManager',
    'Src/Screens/SpeedScreen',
    'Src/Screens/DisplayDriver',
    'Src/TimeFont',
    'Src/GPS/GPSThread',
    'Src/GPS/GPSDataModel',
    'Src/GPS/GPSOdometer',
    'Src/GPS/GPSSatellitesData',
    'Src/GPSLogger',
    'Src/USBDebugLogger',
]

foreach file : src_files
  gpslogger_targets += gpslogger_compilepp.process(file + '.cpp')
endforeach

gpslogger_application = custom_target('gpslogger_app.ll',
                              input: gpslogger_targets + gpslogger_libs,
                              output: 'gpslogger_app.ll',
                              command: llvm_link_cmd,
                              )

gpslogger_runtarget = run_target('gpslogger-full',
                                 command: nop,
                                 depends: gpslogger_application)

named_elf_targets = []
elf_targets = []
foreach t : ara_gen_freertos_targets
  name_prefix = 'gpslogger-' + t
  ara_target = custom_target(name_prefix + '-os',
                             input: gpslogger_application,
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
    lib_freertos_ll_targets += gpslogger_compile.process(src_file)
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
                                         gpslogger_includes +
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
                             command: llvm_opt_cmd)

  lto_o = custom_target(name_prefix + '-lto_app_os.o',
                        input: lto_app_os,
                        output: name_prefix + '-lto_os_app.ll.o',
                        command: llc_cmd)

  lto_elf = custom_target(name_prefix + '.lto.elf',
                          input: [lto_o,
                                  os_target[1], # startup.s
                                  libsra_ar,
                                 ],
                          output: name_prefix + '.lto.elf',
                          depfile: name_prefix + '.lto.elf.dep',
                          command: clang_cpp +
                                   gpslogger_includes +
                                   ld_flags +
                                   gpslogger_ldflags +
                                   clang_flags)

  elf_target = custom_target(name_prefix + '.elf',
                             input: [o_target,
                                     os_target,
                                     lib_freertos_ll_targets,
                                     libsra_ar,
                                    ],
                             output: name_prefix + '.elf',
                             depfile: name_prefix + '.elf.dep',
                             command: clang_cpp +
                                      gpslogger_includes +
                                      ld_flags +
                                      gpslogger_ldflags +
                                      clang_flags)

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

  if get_option('enable_gpslogger_tests')
    test('run_qemu_' + name_prefix,
         py3_inst,
         args: [qemu_test_runner,
                qemu_cmd,
                'gpslogger',
                elf_target,
               ],
         env: [python_path],
         workdir: meson.current_source_dir(),
         suite: 'gpslogger',
         is_parallel: false,
        )
  endif


endforeach

run_target('compare_nm-gpslogger', command: [compare_nm, nm.path(), named_elf_targets])
run_target('compare_size-gpslogger', command: [size, elf_targets])
run_target('compare_time-gpslogger', command: [compare_time, meson.build_root(), 'gpslogger'], depends: elf_targets)
custom_target('analyze-gpslogger',
              command: [files('GPSLoggerExperiment.py'), '-d', meson.current_build_dir(),
                        '-s',
                        '--run-dir', meson.build_root()],
              output: ['gpslogger_result.dref',
                       'gpslogger_raw.dref'],
              console: true,
              depends: elf_targets)
