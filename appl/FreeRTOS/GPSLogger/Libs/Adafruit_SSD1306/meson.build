src_files = [
  'Adafruit_SSD1306.cpp',
]

libadafruitssd_targets = []
foreach file : src_files
  libadafruitssd_targets += gpslogger_compilepp.process(file)
endforeach

libadafruitssd = custom_target('libadafruitssd-link',
                               input: libadafruitssd_targets,
                               output: 'libadafruitssd.ll',
                               command: llvm_link_cmd
                              )



gpslogger_libs += libadafruitssd
