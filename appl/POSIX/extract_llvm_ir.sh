# - This script extracts the LLVM IR of a generated binary tracked by WLLVM -
#
# Note: To build a project with Makefile rather use build_makefile_app.sh.
#       This script will automatically invoke this file.
#
# Dependencies: whole-program-llvm (https://github.com/travitch/whole-program-llvm)
#
#               --> install via "pip3 install wllvm
#
# Usage: (Set the environment variables described below for the script)
#   BINARY_FILE=<binary file> \
#   OUTPUT_FILE=<output file> \
#   ./extract_llvm_ir.sh

# Required environment variables
readonly BINARY_FILE       # The path to the binary file from which to extract the LLVM IR.
readonly OUTPUT_FILE       # This is the output file of this script.

# Optional environment variables
readonly EXTRACT_BC_ARGS   # Arguments to be applied to the WLLVM extract-bc tool. [optional]
#        EXTRACT_BC        # Command to execute extract-bc [optional, default: "extract-bc"]
#        LLVM_DIS          # Command to execute llvm-dis [optional, default: "llvm-dis"]


if [ "x${BINARY_FILE}" = "x" ] || [ "x${OUTPUT_FILE}" = "x" ] ; then
    echo "Missing argument(s)!"
    echo "Usage: (Set the required environment variables)"
    echo "BINARY_FILE=<binary file> \\"
    echo "OUTPUT_FILE=<output file> \\"
    echo "./extract_llvm_ir.sh"
    exit 1
fi

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


BITCODE_NAME=$(basename "${BINARY_FILE}" | cut -f 1 -d '.')
if [ $? -gt 0 ] ; then
    exit 1
fi

# Generate .bc bitcode
${EXTRACT_BC} ${EXTRACT_BC_ARGS} -o "${BITCODE_NAME}".bc "${BINARY_FILE}" || exit 1

# Dissassemble .bc -> .ll
${LLVM_DIS} -o "${OUTPUT_FILE}" "${BITCODE_NAME}".bc || exit 1
rm "${BITCODE_NAME}".bc