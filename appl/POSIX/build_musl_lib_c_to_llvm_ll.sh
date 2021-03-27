
#  - This script compiles the musl lib-c to llvm .ll code -
#
# Dependencies: whole-program-llvm (https://github.com/travitch/whole-program-llvm)
#
#               --> install via "pip3 install wllvm"
#
# Usage: 
#   build_musl_lib_c_to_llvm_ll.sh <musl libc source code>

readonly MUSL_LIB_C_SRC_PATH="$1"
readonly OUTPUT_FILE="$2"

if [ "x${MUSL_LIB_C_SRC_PATH}" = "x" ] || [ "x${OUTPUT_FILE}" = "x" ] ; then
    echo "Missing argument(s)!"
    echo "Usage:"
    echo "   build_musl_lib_c_to_llvm_ll.sh <musl libc source code> <output file>" 
    exit
fi

# Make sure that this file will be executed in the dir of that file
cd "$(dirname "$0")" || exit

if ! [ -e "${MUSL_LIB_C_SRC_PATH}"/configure ]; then
    echo "The path: \"${MUSL_LIB_C_SRC_PATH}\" is not the musl libc source dir"
    exit
fi

# Compile musl lib-c with wllvm
export LLVM_COMPILER=clang
(cd "${MUSL_LIB_C_SRC_PATH}" && CC=wllvm WLLVM_CONFIGURE_ONLY=1 ./configure)
(cd "${MUSL_LIB_C_SRC_PATH}" && make)

# Generate .bc bitcode
extract-bc -o libc.bc "${MUSL_LIB_C_SRC_PATH}"/lib/libc.so

# Dissassemble .bc -> .ll
llvm-dis -o "${OUTPUT_FILE}" libc.bc
rm libc.bc

echo ""
echo "The musl lib-c as .ll is located in" "${OUTPUT_FILE}"