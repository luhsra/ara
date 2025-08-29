# experiment scripts
if arm_enabled
  # TODO make it possible to run the analysis tests without ARM toolchain
  subdir('FreeRTOS')
endif

# Xen must be loaded before Autosar in order to find its targets!
subdir('Xen')

# AUTOSAR examples
# it is POSIX only currently
if posix_enabled
  subdir('AUTOSAR')
endif
