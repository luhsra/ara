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
profiles_list = []
foreach target : ara_gen_freertos_targets
  name_prefix = 'gpslogger-' + target
  if get_option('execute_ara')
    ara_target = custom_target(name_prefix + '-os',
                               input: gpslogger_application,
                               depfile: name_prefix+ '-os.cc.dep',
                               output: [name_prefix + '-os.cc',
                                        name_prefix + '-os.cc.startup.s',
                                        name_prefix + '-modifiedapp.ll',
                                        name_prefix + '-os.cc.freertos_overrides.h',
                                       ],
                               command: get_variable('ara_gen_cmd_' + target)
                              )
  else
    ara_target = disabler()
  endif
  os_target = [ara_target[0], ara_target[1]]
  app_aramodified_ll = ara_target[2]
  freertos_overrides = ara_target[3]

  # compile freertos
  freertos_ll_targets = []
  foreach src: freertos_src_list
    ll_target = custom_target(name_prefix + '-freertos_' + src,
                              input: get_variable('libfreertos_src_vanilla_' +src),
                              output: name_prefix + '-freertos_' +src + '.c.ll',
                              depfile: name_prefix + '-freertos_' +src + '.dep',
                              depends: ara_target,
                              command: clang_c +
                                       gpslogger_includes +
                                       ir_flags +
                                       gpslogger_cflags +
                                       ['-DFREERTOS_OVERRIDES="'+freertos_overrides.full_path()+'"'] +
                                       clang_flags)
    freertos_ll_targets += ll_target
  endforeach

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
                                 freertos_ll_targets],
                         output: name_prefix + '-os_app.ll',
                         command: llvm_link_cmd)


  foreach lto_version : ['none', 'standard', 'rle2']
    lto_prefix = name_prefix + '-' + lto_version
    lto_app_os = custom_target(lto_prefix + '-app_os.ll',
                               input: app_os,
                               depends: [sparse_rle2],
                               output: lto_prefix + '-os_app.ll',
                               command: get_variable('llvm_lto_cmd_' + lto_version))

    lto_o = custom_target(lto_prefix + '-app_os.o',
                          input: lto_app_os,
                          output: lto_prefix + '-os_app.ll.o',
                          command: llc_cmd)

    lto_elf = custom_target(lto_prefix + '.elf',
                            input: [lto_o,
                                    os_target[1], # startup.s
                                    libsra_ar,
                                    # get_variable('libfreertos_' + target)
                                   ],
                            output: lto_prefix + '.elf',
                            depfile: lto_prefix + '.elf.dep',
                            depend_files: default_linkerscript,
                            command: clang_cpp +
                                     gpslogger_includes +
                                     ld_flags +
                                     gpslogger_ldflags +
                                     ['-T' + default_linkerscript ] +
                                     clang_flags)

    bin_target = custom_target(lto_prefix + '.bin',
                               input: [lto_elf],
                               output: lto_prefix + '.bin',
                               command: objcopy_cmd)


    run_target('flash_' + lto_prefix, command: [st_flash, 'write', bin_target, '0x8000000'])
    run_target('size_' + lto_prefix, command: [size, '-A', lto_elf])
    run_target('run_gdb_hw_' + lto_prefix, command: [gdb_hw_script, lto_elf])
    run_target('run_qemu_' + lto_prefix, command: [qemu_cmd, lto_elf])
    run_target('run_gdb_qemu_' + lto_prefix, command: [gdb_qemu_cmd, lto_elf])
    elf_targets += lto_elf
    named_elf_targets += [target + '-' + lto_version, lto_elf]
    profiles_list += ['--profiles', target + '-' + lto_version]

    if get_option('enable_gpslogger_tests')
      test('validate_generator_' + lto_prefix,
           py3_inst,
           args: [validate_generator_runner,
                  'gpslogger',
                  target,
                  ara_target,
                  os_target[0].full_path(),
                  lto_elf,
                 ],
           workdir:  meson.current_source_dir(),
           suite: 'generator'
          )
    endif

    if get_option('enable_gpslogger_tests')
      test('run_qemu_' + name_prefix,
           py3_inst,
           args: [qemu_test_runner,
                  qemu_cmd,
                  'gpslogger',
                  lto_elf,
                 ],
           env: [python_path],
           workdir: meson.current_source_dir(),
           suite: 'gpslogger',
           is_parallel: false,
          )
    endif
    endforeach # lto_verison


endforeach # ara specialization

run_target('compare_nm-gpslogger', command: [compare_nm, nm.path(), named_elf_targets])
run_target('compare_size-gpslogger', command: [size, elf_targets])
run_target('compare_time-gpslogger', command: [compare_time, meson.build_root(), 'gpslogger'], depends: elf_targets)
timing_exp_result = custom_target('analyze_timing-gpslogger',
                                  command: [GenericTimingExperiment, '-d', meson.current_build_dir(),
                                            '-s',
                                            '--title', 'gpslogger',
                                            profiles_list,
                                            '--run-dir', meson.build_root()],
                                  output: ['timing_result-gpslogger.dref',
                                           'timing_result_raw-gpslogger.dref'],
                                  console: true,
                                  depends: elf_targets)

run_target('show-timing_result-gpslogger.dref',
             command: [#'strace',
               ShowGenericTimingExperiment,
               profiles_list,
               '--title', 'gpslogger',],
             depends: timing_exp_result,
            )
run_target('show_old-timing_result-gpslogger.dref',
           command: [#'strace',
             ShowGenericTimingExperiment,
             profiles_list,
             '--title', 'gpslogger',],
          )
