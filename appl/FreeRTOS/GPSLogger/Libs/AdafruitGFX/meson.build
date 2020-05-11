src_files = [
  'Adafruit_GFX.cpp',
]

libadafruitgfx_targets = []
foreach file : src_files
  libadafruitgfx_targets += gpslogger_compilepp.process(file)
endforeach

libadafruitgfx = custom_target('libadafruitgfx-link',
                               input: libadafruitgfx_targets,
                               output: 'libadafruitgfx.ll',
                               command: llvm_link_cmd
                              )

gpslogger_libs += libadafruitgfx
