# experiment scripts
if arm_enabled
  # TODO make it possible to run the analysis tests without ARM toolchain
  subdir('FreeRTOS')
endif

# AUTOSAR examples
# it is POSIX only currently
if posix_enabled
  subdir('AUTOSAR')
endif

# Bare Metal OS for Xen
subdir('Xen/bareMetal')

# Xen must be loaded after AUTOSAR, since its guest include Autosar targets
subdir('Xen')
