gpslogger_dir = meson.current_source_dir()

gpslogger_includes = [join_paths([gpslogger_dir, 'Libs', 'AdafruitGFX']),
                      join_paths([gpslogger_dir, 'Libs', 'Adafruit_SSD1306']),
                      join_paths([gpslogger_dir, 'Libs', 'arduino']),
                      join_paths([gpslogger_dir, 'Libs', 'FreeRTOS'])]

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
                                    depend_files: freertos_includes,
                                    output: 'gpslogger-' + file.underscorify() + '.ll',
                                    depfile: file.underscorify() + '_deps',
                                    command : [clang,
                                               '-I', gpslogger_includes[0],
                                               '-I', gpslogger_includes[1],
                                               '-I', gpslogger_includes[2],
                                               '-I', gpslogger_includes[3],
                                               '@INPUT0@',
                                               '-o', '@OUTPUT@', '-MD', '-MF', '@DEPFILE@', cxx_std] +
                                              clang_flags)
endforeach

gpslogger_runtarget = run_target('gpslogger-full',
                                 command: nop,
                                 depends: gpslogger_targets)
