# Hardware dependent code
if(${CONFIG_ARCH} STREQUAL "i386")
  add_subdirectory(i386)
elseif(${CONFIG_ARCH} STREQUAL "ARM")
  add_subdirectory(arm)
elseif(${CONFIG_ARCH} STREQUAL "posix")
  add_subdirectory(posix)
elseif(${CONFIG_ARCH} STREQUAL "patmos")
  add_subdirectory(patmos)
elseif(CONFIG_ARCH STREQUAL "osek-v")
  add_subdirectory(osek-v)
else()
  message(FATAL_ERROR "Hardware platform not found :(")
endif()

## Generic startup code
add_subdirectory(generic)
