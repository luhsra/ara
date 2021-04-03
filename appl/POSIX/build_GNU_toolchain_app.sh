#  - This script builds an app with uses the GNU toolchain to llvm .ll code -
#
# Dependencies: whole-program-llvm (https://github.com/travitch/whole-program-llvm)
#
#               --> install via "pip3 install wllvm"
#
# Usage: 
#   build_GNU_toolchain_app.sh <project path> <binary file> <output file> <configure arguments (optional)>

readonly PROJECT_PATH="$1"      # The path to the project source dir of the program to be build.
readonly BINARY_FILE="$2"       # The path to the binary file which will be created by the projects Makefile.
readonly OUTPUT_FILE="$3"       # This is the output file of this script.
readonly CONFIGURE_ARGS="$4"    # Arguments to be applied to the ./configure script in ${PROJECT_PATH}. [optional]

if [ "x${PROJECT_PATH}" = "x" ] || [ "x${BINARY_FILE}" = "x" ] || [ "x${OUTPUT_FILE}" = "x" ] ; then
    echo "Missing argument(s)!"
    echo "Usage:"
    echo "   build_GNU_toolchain_app.sh <project path> <binary file> <output file> <configure arguments (optional)>" 
    exit
fi

# Make sure that this file will be executed in the dir of that file
cd "$(dirname "$0")" || exit

if ! [ -e "${PROJECT_PATH}"/configure ]; then
    echo "The path: \"${PROJECT_PATH}\" is not a project source dir!"
    exit
fi

# Compile project with wllvm
export LLVM_COMPILER=clang
(cd "${PROJECT_PATH}" && CC=wllvm WLLVM_CONFIGURE_ONLY=1 ./configure ${CONFIGURE_ARGS})
(cd "${PROJECT_PATH}" && make)

# Generate .bc bitcode
extract-bc -o app_binary.bc "${BINARY_FILE}"

# Dissassemble .bc -> .ll
llvm-dis -o "${OUTPUT_FILE}" app_binary.bc
rm app_binary.bc