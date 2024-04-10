set(SRCS
  startup.S
  output.cc
  startup.cc
  constructors.cc
  interrupt.cc
  timer.cc
  dispatch.cc
  htif.cc
  fdt.cc
  )

# Create arch library
add_library(arch ${SRCS})
target_link_libraries(arch generic)

# Add to include directories
dosek_include_dir(${CMAKE_CURRENT_SOURCE_DIR})
set(ARCH_INCLUDE_DIRS ${ARCH_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL STRING)


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

  set(LINKER_SCRIPT "${PROJECT_SOURCE_DIR}/arch/osek-v/linker.ld")

  set_target_properties(${APP} ${PRELINK} PROPERTIES
    LINK_FLAGS " -lgcc -Wl,-T ${LINKER_SCRIPT} ${TC_TARGET_LDFLAGS} --linker-prefix=${CMAKE_CURRENT_BINARY_DIR}/${APP}"
    LINK_DEPENDS ${LINKER_SCRIPT})

  # add to executables list
  set(EXECUTABLES ${EXECUTABLES} ${APP} CACHE INTERNAL STRING)

  add_custom_command(TARGET ${APP} POST_BUILD
    COMMENT "Symlinking rocket config ${NAME}"
    COMMAND ln -sf ${CMAKE_CURRENT_BINARY_DIR}/${APP}/rocket.config ${PROJECT_BINARY_DIR}/${APP}.rocket.config
  )

  # test-${FN}: run the image in spike
  add_custom_target(test-${APP}
    DEPENDS $<TARGET_FILE:${APP}>
    COMMENT "[spike] Running ${APP}"
    COMMAND ${TC_TARGET_SPIKE} -m0x2000:134217728 $<TARGET_FILE:${APP}>
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
    TIMEOUT 10
    DEPENDS ${APP}:build)
endmacro()
