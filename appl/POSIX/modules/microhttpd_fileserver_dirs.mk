# fileserver_dirs.c in libmicrohttpd 0.9.73
# The file fileserver_example_dirs.c will be compiled within the build process of libmicrohttpd.
# So we only need to extract the LLVM IR code with WLLVM and link it to libmicrohttpd.

MICROHTTPD_FILESERVER_DIRS ?= $(LIBMICROHTTPD_DIR)/src/examples/.libs/fileserver_example_dirs

PROJECT_NAMES += microhttpd_fileserver_dirs
BIN_PROJECT_NAMES += microhttpd_fileserver_dirs

# Link
$(OBJ_BUILD)/microhttpd_fileserver_dirs.ll: $(OBJ_BUILD)/microhttpd_fileserver_dirs_without_lib.ll $(BUILD_DIR)/libmicrohttpd.ll
	$(LINK_TOGETHER)

# Get LLVM IR
$(OBJ_BUILD)/microhttpd_fileserver_dirs_without_lib.ll: $(BUILD_DIR)/libmicrohttpd.ll
	
	BINARY_FILE="$(MICROHTTPD_FILESERVER_DIRS)" \
	OUTPUT_FILE="$@" \
		./extract_llvm_ir.sh