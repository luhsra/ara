libhal_targets = []
subdir('system/STM32F1/HAL_Src')

# libhal_targets += gpslogger_compile.process('system/STM32F1/CMSIS_Src/startup_stm32f103xb.s')



libhal = custom_target('libhal-link',
                       input: libhal_targets,
                       output: 'libhal.ll',
                       command: llvm_link_cmd
                      )

gpslogger_libs += libhal
