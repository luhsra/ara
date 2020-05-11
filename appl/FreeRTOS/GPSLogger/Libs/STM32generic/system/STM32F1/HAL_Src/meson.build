src_files = [
  'stm32f1xx_hal.c',
  'stm32f1xx_hal_cortex.c',
  'stm32f1xx_hal_rcc.c',
  'stm32f1xx_hal_rcc_ex.c',
  'stm32f1xx_hal_pwr.c',
  'stm32f1xx_hal_dma.c',
  'stm32f1xx_hal_gpio.c',
  'stm32f1xx_hal_i2c.c',
  'stm32f1xx_hal_pcd.c',
  'stm32f1xx_hal_pcd_ex.c',
  'stm32f1xx_hal_spi.c',
  'stm32f1xx_ll_usart.c',
  'stm32f1xx_ll_usb.c',
  'system_stm32f1xx.c',
]

obj_targets = []
foreach src : src_files
  libhal_targets += gpslogger_compile.process(src)
endforeach
