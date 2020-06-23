# (Emulated) RAM size
set(RAM_SIZE "16" CACHE STRING "(Emulated) RAM size in MB")

# Debugger to use
find_program(DEBUGGER "gdb" DOC "Debugger (gdb/ddd)")

# (Random) port for debugging
string(RANDOM LENGTH 4 ALPHABET "123456789" DPORT)
set(DEBUG_PORT ${DPORT} CACHE STRING "Debug (stub) port")
message(STATUS "[${PROJECT_NAME}] Using port ${DEBUG_PORT} for debug stub")

# Enable emulators
OPTION(X86_TARGET_BOCHS "Bochs" OFF)
OPTION(X86_TARGET_QEMU "QEMU" OFF)

# setup x86-32 specific sources
set(SRCS
    dispatch.cc
    terminal.cc
    startup.cc
    itimer.cc
    output.cc
    signalinfo.cc
    irq.cc
    mp.cc
)

# Create arch library
add_library(arch ${SRCS})
target_link_libraries(arch generic pthread)

# Add to include directories
dosek_include_dir(${CMAKE_CURRENT_SOURCE_DIR})
set(ARCH_INCLUDE_DIRS ${ARCH_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL STRING)

# Setup linker script
set(LINKER_SCRIPT "${PROJECT_BINARY_DIR}/linker.ld" CACHE INTERNAL STRING)
configure_file(linker.ld.in ${LINKER_SCRIPT})

# Show target specific sources, linker script
message(STATUS "Linker script: ${LINKER_SCRIPT}")

# POSIX dOSEK executable macro
macro(dosek_executable APP)
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

    # The actual executable
    add_executable(${APP} ${ADD_EXECUTABLE_OPTIONS} ${SOURCES})
    target_link_libraries(${APP} ${TARGET_LIBS})

    # set definitions
    if(DOSEK_EXECUTABLE_DEFINITIONS)
      set_target_properties(${APP} PROPERTIES COMPILE_DEFINITIONS ${DOSEK_EXECUTABLE_DEFINITIONS})
    endif()

    # Set custom linker script/flags
    # libgcc added here to be used as needed (compiler helper functions)and not included in full
    set_target_properties(${APP} PROPERTIES LINK_FLAGS
      "-lgcc  ${TC_TARGET_LDFLAGS} -Wl,-T${LINKER_SCRIPT} --linker-prefix=${CMAKE_CURRENT_BINARY_DIR}/${APP}")

    # add to executables list
    set(EXECUTABLES ${EXECUTABLES} ${APP} CACHE INTERNAL STRING)


  # test-${FN}: run the image in spike
  add_custom_target(test-${APP}
    DEPENDS $<TARGET_FILE:${APP}>
    COMMENT "[Linux] Running ${APP}"
    COMMAND $<TARGET_FILE:${APP}>
  )
endmacro()

macro(dosek_add_build_test APP)
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
      TIMEOUT 10
      DEPENDS ${APP}:build)
endmacro()
