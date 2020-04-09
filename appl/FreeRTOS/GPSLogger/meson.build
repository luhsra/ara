gpslogger_dir = meson.current_source_dir()

gpslogger_includes = ['-I', join_paths([gpslogger_dir, 'Libs', 'AdafruitGFX']),
                      '-I', join_paths([gpslogger_dir, 'Libs', 'Adafruit_SSD1306']),
                      '-I', join_paths([gpslogger_dir, 'Libs', 'arduino']),
                      '-I', join_paths([gpslogger_dir, 'Libs', 'FreeRTOS']),
                     ]
if get_option('arch') == 'arm'
  gpslogger_includes += ['-I', '/usr/lib/arm-none-eabi/include/',
                         '-I', '/usr/include/newlib/',]
endif

gpslogger_targets = []

src_files = [
    'Src/GPSLogger',
    'Src/SDThread',
    'Src/LEDThread',
    'Src/ButtonsThread',
    'Src/SdFatSPIDriver',
    'Src/Screens/ScreenManager',
    'Src/Screens/SpeedScreen',
    'Src/Screens/DisplayDriver',
    'Src/GPS/GPSThread',
    'Src/GPS/GPSDataModel',
    'Libs/Adafruit_SSD1306/Adafruit_SSD1306'
]


foreach file : src_files
  gpslogger_targets += custom_target('gpslogger-' + file.underscorify(),
                                    input: file + '.cpp',
                                    output: 'gpslogger-' + file.underscorify() + '.ll',
                                    depfile: file.underscorify() + '_deps',
                                    command : clang_cpp +
                                              libs_includes +
                                              gpslogger_includes +
                                              ir_flags +
                                              clang_flags)
endforeach

gpslogger_runtarget = run_target('gpslogger-full',
                                 command: nop,
                                 depends: gpslogger_targets)

gpslogger_full_static_os = custom_target('gpslogger-instances_full_static-os',
                                         input: gpslogger_targets,
                                         depfile: 'instances_full_static-os.cc.dep',
                                         output: 'instances_full_static-os.cc',
                                         command: ara_gen_cmd_instances_full_static,
                                        )

gpslogger_application = custom_target('gpslogger-application.ll',
                                      input: gpslogger_targets,
                                      output: 'gpslogger-application.ll',
                                      command: [llvm_link,
                                                '-S',
                                                '-o', '@OUTPUT@',
                                                '@INPUT@',
                                                ]
                                      )
