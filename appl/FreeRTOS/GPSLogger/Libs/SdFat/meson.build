src_files = [
  'FatLib/FatFile.cpp',
  'FatLib/FatFileLFN.cpp',
  'FatLib/FatFilePrint.cpp',
  'FatLib/FatFileSFN.cpp',
  'FatLib/FatVolume.cpp',
  'FatLib/FmtNumber.cpp',
  'SdCard/SdSpiCard.cpp',
  'SpiDriver/SdSpiSTM32F1.cpp',
]

libsdfat_targets = []
foreach file : src_files
  libsdfat_targets += gpslogger_compilepp.process(file)
endforeach

libsdfat = custom_target('libsdfat-link',
                         input: libsdfat_targets,
                         output: 'libsdfat.ll',
                         command: llvm_link_cmd,
                        )

gpslogger_libs += libsdfat
