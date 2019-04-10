src_path = 'Src'

gpslogger_dir = meson.current_source_dir()

gpslogger_includes = [join_paths([gpslogger_dir, 'Libs', 'AdafruitGFX']),
                      join_paths([gpslogger_dir, 'Libs', 'Adafruit_SSD1306']),
                      join_paths([gpslogger_dir, 'Libs', 'arduino']),
                      join_paths([gpslogger_dir, 'Libs', 'FreeRTOS'])]

gpslogger_targets = []
foreach file : ['GPSLogger', 'SDThread', 'LEDThread', 'ButtonsThread', 'SdFatSPIDriver',
                'Screens/ScreenManager', 'Screens/SpeedScreen', 'Screens/DisplayDriver',
                'GPS/GPSThread', 'GPS/GPSDataModel']
  gpslogger_targets += custom_target('gpslogger-' + file.underscorify(),
                                    input: join_paths(src_path, file + '.cpp'),
                                    depend_files: freertos_includes,
                                    output: 'gpslogger-' + file.underscorify() + '.ll',
                                    depfile: file.underscorify() + '_deps',
                                    command : [clang,
                                               '-I', gpslogger_includes[0],
                                               '-I', gpslogger_includes[1],
                                               '-I', gpslogger_includes[2],
                                               '-I', gpslogger_includes[3],
                                               '@INPUT0@',
                                               '-o', '@OUTPUT@', '-MD', '-MF', '@DEPFILE@'] +
                                              clang_flags)
endforeach

gpslogger_runtarget = run_target('gpslogger-full',
                                 command: nop,
                                 depends: gpslogger_targets)
