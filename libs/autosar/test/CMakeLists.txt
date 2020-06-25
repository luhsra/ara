# Build all test cases and run ctest -V
# mainly for manual use on commandline
#

set(SRCS
  test.cc
)

add_library(libtest ${SRCS})


# The traditional 'make test' has no dependency on any
# test case. Here, we add all test cases as dependency
add_custom_target(tests)


add_custom_target(build
    ${CMAKE_CTEST_COMMAND} -V -R build
    DEPENDS tests
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "[${PROJECT_NAME}] Building testcases (only)"
)


# Convert ctest output to xUnit format for jenkins
set(CONVERTPY ${PROJECT_SOURCE_DIR}/toolchain/ctest2jenkins/convert.py)
set(CONVXSL   ${PROJECT_SOURCE_DIR}/toolchain/ctest2jenkins/conv.xsl)
set(XUNITOUTPUT ${PROJECT_BINARY_DIR}/BaseTest.xml)


# Custom target generating xUnit output (see below)
add_custom_target( ctest2jenkins
    DEPENDS ${XUNITOUTPUT}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "[${PROJECT_NAME}] Generating xUnit output of CTest results"
    )

include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
  set(CTEST_BUILD_FLAGS -j${N})
  set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${N})
endif()


# Generate ExperimentalTest results and convert to xUnit xml output
add_custom_command(
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMAND ctest ${CTEST_BUILD_FLAGS} -V  -D ExperimentalTest || true
    COMMAND python3 ${CONVERTPY} ${PROJECT_BINARY_DIR} ${CONVXSL} > BaseTest.xml
    DEPENDS tests
    OUTPUT ${XUNITOUTPUT}
)
