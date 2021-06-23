#  - This script builds an app, with uses a Makefile, to LLVM IR code -
#
# Dependencies: whole-program-llvm (https://github.com/travitch/whole-program-llvm)
#
#               --> install via "pip3 install wllvm"
#
# Usage: (Set the environment variables described below for the script)
#   PROJECT_PATH=<project path> \
#   BINARY_FILE=<binary file> \
#   OUTPUT_FILE=<output file> \
#   ./build_makefile_app.sh

# Required environment variables
readonly PROJECT_PATH       # The path to the project source dir of the program to be build.
readonly BINARY_FILE        # The path to the binary file which will be created by the projects Makefile.
readonly OUTPUT_FILE        # This is the output file of this script.

# Optional environment variables
readonly EXEC_CONFIGURE     # if this boolean is set to "true" than this script executes "./configure" before "make" [optional, default: false]
readonly EXEC_MAKE_RULE     # If this var is set than this script executes the rule EXEC_MAKE_RULE "make <EXEC_MAKE_RULE>" after "make". MAKE_ARGS will not applied to this target. [optional]
readonly CONFIGURE_ARGS     # Arguments to be applied to the ./configure script in ${PROJECT_PATH} if EXEC_CONFIGURE is set. [optional]
readonly MAKE_ARGS          # Arguments to be applied to the make call. [optional]
readonly EXTRACT_BC_ARGS    # Arguments to be applied to the WLLVM extract-bc tool. [optional]
readonly LLVM_COMPILER_PATH # The path to the compiler directory used by WLLVM. See WLLVM env var LLVM_COMPILER_PATH. [optional, default: Use standard clang]
#        WLLVM              # Command to execute wllvm [optional, default: "wllvm"]
#        EXTRACT_BC         # Command to execute extract-bc [optional, default: "extract-bc"]
#        LLVM_DIS           # Command to execute llvm-dis [optional, default: "llvm-dis"]


if [ "x${PROJECT_PATH}" = "x" ] || [ "x${BINARY_FILE}" = "x" ] || [ "x${OUTPUT_FILE}" = "x" ] ; then
    echo "Missing argument(s)!"
    echo "Usage: (Set the required environment variables)"
    echo "PROJECT_PATH=<project path> \\"
    echo "BINARY_FILE=<binary file> \\"
    echo "OUTPUT_FILE=<output file> \\"
    echo "./build_makefile_app.sh"
    exit 1
fi

if [ "x${WLLVM}" = "x" ] ; then
    WLLVM="wllvm"
fi
readonly WLLVM

if [ "x${EXTRACT_BC}" = "x" ] ; then
    EXTRACT_BC="extract-bc"
fi
readonly EXTRACT_BC

if [ "x${LLVM_DIS}" = "x" ] ; then
    LLVM_DIS="llvm-dis"
fi
readonly LLVM_DIS

# Make sure that this file will be executed in the dir of that file
cd "$(dirname "$0")" || exit 1

if [ ! -e "${PROJECT_PATH}"/Makefile ] && [ ! -e "${PROJECT_PATH}"/configure ] ; then
    echo "No Makefile or configure script found in \"${PROJECT_PATH}\"!"
    exit 1
fi

# Compile project with wllvm
export LLVM_COMPILER=clang
export LLVM_COMPILER_PATH
if [ "${EXEC_CONFIGURE}" = "true" ] ; then
    (cd "${PROJECT_PATH}" && CC="${WLLVM}" WLLVM_CONFIGURE_ONLY=1 ./configure ${CONFIGURE_ARGS}) || exit 1
    (cd "${PROJECT_PATH}" && make -j$(nproc) ${MAKE_ARGS}) || exit 1
else
    (cd "${PROJECT_PATH}" && make -j$(nproc) CC="${WLLVM}" ${MAKE_ARGS}) || exit 1
fi

if ! [ "x${EXEC_MAKE_RULE}" = "x" ] ; then
    (cd "${PROJECT_PATH}" && make ${EXEC_MAKE_RULE}) || exit 1
fi

# Extract LLVM IR code of ${BINARY_FILE}
# Redirect environment variables from this script to:
    ./extract_llvm_ir.sh