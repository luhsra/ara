src_files= [
  'abi.cpp',
  'Print.cpp',
  'Stream.cpp',
]

libarduino_targets = []
foreach file : src_files
  libarduino_targets += gpslogger_compilepp.process(file)
endforeach

libarduino_targets += gpslogger_compile.process('stm32/stm32_init.c')


libarduino = custom_target('libarduino-link',
                           input: libarduino_targets,
                           output: 'libarduino.ll',
                           command: llvm_link_cmd
                          )

gpslogger_libs += libarduino
