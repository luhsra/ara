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
#   ./build_GNU_toolchain_app.sh

# Required environment variables
readonly PROJECT_PATH      # The path to the project source dir of the program to be build.
readonly BINARY_FILE       # The path to the binary file which will be created by the projects Makefile.
readonly OUTPUT_FILE       # This is the output file of this script.

# Optional environment variables
readonly EXEC_CONFIGURE    # if this boolean is set to "true" than this script executes "./configure" before "make" [optional, default: false]
readonly EXEC_MAKE_INSTALL # If this boolean is set to "true" than this script executes "make install" after "make". [optional, default: false]
readonly CONFIGURE_ARGS    # Arguments to be applied to the ./configure script in ${PROJECT_PATH} if EXEC_CONFIGURE is set. [optional]
readonly MAKE_ARGS         # Arguments to be applied to the make call. [optional]
readonly EXTRACT_BC_ARGS   # Arguments to be applied to the WLLVM extract-bc tool. [optional]
#        LLVM_DIS          # Command to execute llvm-dis [optional, default: "llvm-dis"]


if [ "x${PROJECT_PATH}" = "x" ] || [ "x${BINARY_FILE}" = "x" ] || [ "x${OUTPUT_FILE}" = "x" ] ; then
    echo "Missing argument(s)!"
    echo "Usage: (Set the required environment variables)"
    echo "PROJECT_PATH=<project path> \\"
    echo "BINARY_FILE=<binary file> \\"
    echo "OUTPUT_FILE=<output file> \\"
    echo "./build_GNU_toolchain_app.sh"
    exit
fi

if [ "x${LLVM_DIS}" = "x" ] ; then
    LLVM_DIS="llvm-dis"
fi

# Make sure that this file will be executed in the dir of that file
cd "$(dirname "$0")" || exit

if ! [ -e "${PROJECT_PATH}"/Makefile ] ; then
    echo "No Makefile found in \"${PROJECT_PATH}\"!"
    exit
fi

# Compile project with wllvm
export LLVM_COMPILER=clang
if [ "${EXEC_CONFIGURE}" = "true" ] ; then
    (cd "${PROJECT_PATH}" && CC=wllvm WLLVM_CONFIGURE_ONLY=1 ./configure ${CONFIGURE_ARGS})
    (cd "${PROJECT_PATH}" && make -j$(nproc))
else
    (cd "${PROJECT_PATH}" && make -j$(nproc) CC=wllvm ${MAKE_ARGS})
fi

if [ "${EXEC_MAKE_INSTALL}" = "true" ] ; then
    (cd "${PROJECT_PATH}" && make install)
fi

# Generate .bc bitcode
extract-bc ${EXTRACT_BC_ARGS} -o app_binary.bc "${BINARY_FILE}"

# Dissassemble .bc -> .ll
${LLVM_DIS} -o "${OUTPUT_FILE}" app_binary.bc
rm app_binary.bc