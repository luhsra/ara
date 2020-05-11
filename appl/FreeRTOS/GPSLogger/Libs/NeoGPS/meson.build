src_files = [
  'DMS.cpp',
  'GPSTime.cpp',
  'Location.cpp',
  'NeoTime.cpp',
  'NMEAGPS.cpp',
]

libneogps_targets = []
foreach file : src_files
  libneogps_targets += gpslogger_compilepp.process(file)
endforeach

libneogps = custom_target('libneogps-link',
                          input: libneogps_targets,
                          output: 'libneogps.ll',
                          command: llvm_link_cmd
                         )
gpslogger_libs += libneogps
