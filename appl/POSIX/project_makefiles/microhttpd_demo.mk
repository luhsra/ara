
# demo.c in libmicrohttpd 0.9.73
# The file demo.c will be compiled within the build process of libmicrohttpd.
# So we only need to extract the LLVM IR code with WLLVM and link it to libmicrohttpd.

MICROHTTPD_DEMO_BIN ?= $(LIBMICROHTTPD_DIR)/src/examples/.libs/demo

PROJECT_NAMES += microhttpd_demo
BIN_PROJECT_NAMES += microhttpd_demo

# This demo application needs the postprocessor of libmicrohttpd.
DISABLE_POSTPROCESSOR =

# Link
$(OBJ_BUILD)/microhttpd_demo.ll: $(OBJ_BUILD)/microhttpd_demo_without_lib.ll $(BUILD_DIR)/libmicrohttpd.ll
	$(LINK_TOGETHER)

# Get LLVM IR
$(OBJ_BUILD)/microhttpd_demo_without_lib.ll: $(BUILD_DIR)/libmicrohttpd.ll
	
	BINARY_FILE="$(MICROHTTPD_DEMO_BIN)" \
	OUTPUT_FILE="$@" \
		./extract_llvm_ir.sh