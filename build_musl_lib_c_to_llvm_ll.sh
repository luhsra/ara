
#  - This script compiles the musl lib-c to llvm .ll code -
#
# Dependencies: whole-program-llvm (https://github.com/travitch/whole-program-llvm)
#
#               --> install via "pip3 install wllvm"

# Change this vars to specify another path
readonly MUSL_LIB_C_SRC_PATH=~/Downloads/musl-1.2.2
readonly OUTPUT_FILE=appl/POSIX/musl_libc.ll


# Make sure that this file will be executed in the dir of that file
cd "$(dirname "$0")" || exit

# Compile musl lib-c with wllvm
export LLVM_COMPILER=clang
CC=wllvm WLLVM_CONFIGURE_ONLY=1 "${MUSL_LIB_C_SRC_PATH}"/configure
(cd "${MUSL_LIB_C_SRC_PATH}" && make)

# Generate .bc bitcode
extract-bc -o libc.bc "${MUSL_LIB_C_SRC_PATH}"/lib/libc.so

# Dissassemble .bc -> .ll
llvm-dis -o "${OUTPUT_FILE}" libc.bc
rm libc.bc

echo ""
echo "The musl lib-c as .ll is located in" "${OUTPUT_FILE}"