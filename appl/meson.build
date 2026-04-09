# experiment scripts
if arm_enabled and get_option('build_freertos_apps')
  message('Including FreeRTOS applications.')
  # TODO make it possible to run the analysis tests without ARM toolchain
  subdir('FreeRTOS')
endif

# AUTOSAR examples
if (arm_enabled or posix_enabled or riscv_enabled) and (get_option('build_hypersse_xen') or get_option('build_autosar_apps'))
  message('Including Autosar applications.')
  subdir('AUTOSAR')
endif

# Bare Metal OS for Xen
if get_option('build_hypersse_xen')
  message('Including BareMetal applications."')
  subdir('BareMetal')
endif

# Xen must be loaded after AUTOSAR, since its guest include Autosar targets
if get_option('build_hypersse_xen')
  message('Including Xen applications.')
  subdir('Xen')
endif
