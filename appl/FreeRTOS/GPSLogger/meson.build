src_path = 'Src'

gpslogger_targets = []
foreach file : ['GPSLogger', 'SDThread', 'LEDThread', 'ButtonsThread', 'SdFatSPIDriver',
                'Screens/ScreenManager', 'Screens/SpeedScreen',
                'GPS/GPSThread', 'GPS/GPSDataModel']
  gpslogger_targets += custom_target('gpslogger-' + file.underscorify(),
                                    input : [join_paths(src_path, file + '.cpp')] + freertos_includes,
                                    output : ['gpslogger-' + file.underscorify() + '.ll', file.underscorify() + '_deps'],
                                    command : [clang, '@INPUT0@',
                                               '-o', '@OUTPUT0@', '-MD', '-MF', '@OUTPUT1@'] +
                                              clang_flags)
endforeach
