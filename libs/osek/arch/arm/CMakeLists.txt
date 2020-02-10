# (Emulated) RAM size
set(RAM_SIZE "16" CACHE STRING "(Emulated) RAM size in MB")

# Debugger to use
find_program(DEBUGGER "arm-none-eabi-gdb" DOC "Debugger (gdb/ddd)")

# (Random) port for debugging
string(RANDOM LENGTH 4 ALPHABET "123456789" DPORT)
set(DEBUG_PORT ${DPORT} CACHE STRING "Debug (stub) port")
message(STATUS "[${PROJECT_NAME}] Using port ${DEBUG_PORT} for debug stub")

# Include platform-specific files
add_subdirectory(platforms)
dosek_include_dir(${ARCH_INCLUDE_DIRS})

# Enable emulators
# GEM5 is not well tested
# OPTION(ARM_TARGET_GEM5 "gem5" ON)
# if(ARM_TARGET_GEM5)
#	set(ADDITIONAL_TARGETS ${ADDITIONAL_TARGETS}
#		${CMAKE_CURRENT_SOURCE_DIR}/gem5 CACHE INTERNAL STRING)
#endif()

# Add QEMU as an additional target
set(ADDITIONAL_TARGETS ${ADDITIONAL_TARGETS}
  ${CMAKE_CURRENT_SOURCE_DIR}/qemu CACHE INTERNAL STRING)


# setup ARM specific sources
set(SRCS
    constructors.cc
	startup.cc
	gic.cc
	irq.S
	platforms/${PLATFORM_DIR}/serial.cc
	platforms/${PLATFORM_DIR}/translation_table.S
	platforms/${PLATFORM_DIR}/machine_impl.cc
    timer.cc
	output.cc
	dispatch.cc
	syscall.cc
	reschedule-ast.cc
    machine.cc
    memutil.cc
)

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/platforms/${PLATFORM_DIR}/startup.S)
  set(SRCS ${SRCS} platforms/${PLATFORM_DIR}/startup.S)
else()
	set(SRCS ${SRCS} startup.S)
endif()

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/platforms/${PLATFORM_DIR}/CMakeLists.txt)
  add_subdirectory(platforms/${PLATFORM_DIR})
endif()


# Create arch library
add_library(arch ${SRCS})
target_link_libraries(arch generic)

# Add to include directories
dosek_include_dir(${CMAKE_CURRENT_SOURCE_DIR})
set(ARCH_INCLUDE_DIRS ${ARCH_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL STRING)

# Set linker script template
set(LINKER_TEMPLATE ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld.in CACHE INTERNAL STRING)

# ARM dOSEK executable macro
# usage: dosek_executable(ELFFILE ... [DEFINTIONS ...])
# Creates dOSEK executable named ELFFILE. All parameters after ELFFILE until
# (optional) DEFINITIONS are passed directly to add_executable.
# To set compile definitions specify them after DEFINITIONS keyword.
macro(dosek_executable APP)
  # parse DEFINITIONS
  set(options "EXCLUDE_FROM_ALL")
  set(oneValueArgs "LINKER_SCRIPT")
  set(multiValuedParameters DEFINITIONS LIBS SOURCES)
  cmake_parse_arguments(DOSEK_EXECUTABLE "${options}" "${oneValueArgs}" "${multiValuedParameters}" ${ARGN} )
  set(SOURCES ${DOSEK_EXECUTABLE_SOURCES} ${DOSEK_EXECUTABLE_UNPARSED_ARGUMENTS})
  set(DEFINITIONS ${DOSEK_EXECUTABLE_DEFINITIONS})
  set(ADD_EXECUTABLE_OPTIONS "")
  if(${DOSEK_EXECUTABLE_EXCLUDE_FROM_ALL} STREQUAL "TRUE")
    set(ADD_EXECUTABLE_OPTIONS "EXCLUDE_FROM_ALL")
  endif()

  # libraries to link with application
  set(TARGET_LIBS os arch ${DOSEK_EXECUTABLE_LIBS})

  # First executable with empty, weak page tables
  set(PRELINK ${APP}.prelink.elf)
  add_executable(${PRELINK} ${ADD_EXECUTABLE_OPTIONS} ${SOURCES})
  set_target_properties(${PRELINK} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  target_link_libraries(${PRELINK} ${TARGET_LIBS})

  # The actual executable
  add_executable(${APP} ${ADD_EXECUTABLE_OPTIONS} ${SOURCES} )
  target_link_libraries(${APP} ${TARGET_LIBS})

  # set definitions
  if(DOSEK_EXECUTABLE_DEFINITIONS)
    set_target_properties(${APP} ${PRELINK} PROPERTIES COMPILE_DEFINITIONS ${DOSEK_EXECUTABLE_DEFINITIONS})
  endif()

  # Set custom linker script/flags
  # libgcc added here to be used as needed (compiler helper functions)and not included in full
  if(DOSEK_EXECUTABLE_LINKER_SCRIPT)
    set(LINKER_SCRIPT ${DOSEK_EXECUTABLE_LINKER_SCRIPT})
  else()
    set(LINKER_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/${APP}_linker.ld)
  endif()
  set_target_properties(${APP} ${PRELINK} PROPERTIES
    LINK_FLAGS "-lgcc -Wl,-T ${LINKER_SCRIPT} ${TC_TARGET_LDFLAGS} --linker-prefix=${CMAKE_CURRENT_BINARY_DIR}/${APP}"
    LINK_DEPENDS ${LINKER_SCRIPT})

    # Add Platform specific stuff
    if(COMMAND dosek_arm_platform_executable)
      dosek_arm_platform_executable(${APP})
    endif()

    ################################################################
    # Run the resulting binary
    ################################################################
    set(ELF_ABS ${PROJECT_BINARY_DIR}/${APP})
    set(QEMU_ARGS -M xilinx-zynq-a9 -m ${RAM_SIZE} -no-reboot -nographic -serial null -serial mon:stdio)
    add_custom_target(test-${APP}
      DEPENDS ${APP}
      COMMENT "[${PROJECT_NAME}] Running ${ELF} in qemu-system-arm no-graphic mode."
      COMMAND qemu-system-arm ${QEMU_ARGS} -kernel ${ELF_ABS}
      )
endmacro()

macro(dosek_add_build_test APP)
  # ${FN}:build: add a CTest build test
  add_test(${APP}:build "${CMAKE_COMMAND}" --build ${CMAKE_BINARY_DIR} --target ${APP})
  set_tests_properties(${APP}:build PROPERTIES
    TIMEOUT 100
    DEPENDS dosek_base_libraries
    )
endmacro()

macro(dosek_add_run_test APP)
  # Execute the execution in spike as a functional test.
  add_test(${APP} "${CMAKE_COMMAND}" --build ${CMAKE_BINARY_DIR} --target test-${APP})
  set_tests_properties(${APP} PROPERTIES
    PASS_REGULAR_EXPRESSION "SUCCESS.+ALL OK"
    FAIL_REGULAR_EXPRESSION "FAIL"
    TIMEOUT 20
    DEPENDS ${APP}:build)
endmacro()



#macro(dosek_add_run_test FN)
#    add_test(${FN} ${GEM5} ${GEM5_OPTIONS} ; cat m5out/system.terminal)
#    add_test(${FN} qemu-system-arm -M xilinx-zynq-a9 -m ${RAM_SIZE} -no-reboot -nographic -serial null -serial mon:stdio -kernel "${PROJECT_BINARY_DIR}/${FN}")#
    #set_tests_properties(${FN} PROPERTIES PASS_REGULAR_EXPRESSION "SUCCESS.+ALL OK" FAIL_REGULAR_EXPRESSION "FAIL" TIMEOUT 20)
#    add_dependencies( tests ${FN} )
#endmacro()
