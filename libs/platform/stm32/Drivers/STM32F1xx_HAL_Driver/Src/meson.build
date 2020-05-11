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
]

obj_targets = []
foreach src : src_files
  lib_platform_src_files += files(src)
  obj_target = custom_target(src,
                             input: src,
                             output: src+'.o',
                             depfile: src+'.dep',
                             command: clang_c+
                                      libs_includes +
                                      ld_flags +
                                      obj_flags +
                                      clang_flags)
  obj_targets += obj_target
  lib_platform_targets += obj_target
endforeach

libstm_hal_target = custom_target('stm_hal.ar',
                          input: obj_targets,
                          output: 'libstm_hal.a',
                          command: ar_cmd)

# ld_flags += ['-Wl,-L' + meson.current_build_dir()]
