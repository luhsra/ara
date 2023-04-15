set(SRCS
    counter.cc
    helper.cc
    isr.cc
)

add_library(os ${SRCS})
add_library(timing timing.cc)
add_subdirectory(scheduler)

# We add a test that executes a make all. All build tests must depend on this.
add_test(dosek_base_libraries "${CMAKE_COMMAND}" --build ${CMAKE_BINARY_DIR})
set_tests_properties(dosek_base_libraries PROPERTIES
    TIMEOUT 100
)
