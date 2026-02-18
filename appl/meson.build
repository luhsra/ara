# experiment scripts
if arm_enabled
  # TODO make it possible to run the analysis tests without ARM toolchain
  subdir('FreeRTOS')
endif

# AUTOSAR examples
if arm_enabled or posix_enabled or riscv_enabled
  subdir('AUTOSAR')
endif

# Bare Metal OS for Xen
subdir('BareMetal')

# Xen must be loaded after AUTOSAR, since its guest include Autosar targets
if get_option('include_xen')
  subdir('Xen')
endif
