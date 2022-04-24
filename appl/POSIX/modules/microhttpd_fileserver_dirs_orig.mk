# Copy of microhttpd_fileserver_dirs.mk but for building the unmodified original version
# fileserver_dirs.c in libmicrohttpd 0.9.73
# The file fileserver_example_dirs.c will be compiled within the build process of libmicrohttpd.
# So we only need to extract the LLVM IR code with WLLVM and link it to libmicrohttpd.

MICROHTTPD_FILESERVER_DIRS_ORIG ?= $(LIBMICROHTTPD_DIR_ORIG)/src/examples/.libs/fileserver_example_dirs

PROJECT_NAMES += microhttpd_fileserver_dirs_orig
BIN_PROJECT_NAMES += microhttpd_fileserver_dirs_orig

# Link
$(OBJ_BUILD)/microhttpd_fileserver_dirs_orig.ll: $(OBJ_BUILD)/microhttpd_fileserver_dirs_without_lib_orig.ll $(BUILD_DIR)/libmicrohttpd_orig.ll
	$(LINK_TOGETHER)

# Get LLVM IR
$(OBJ_BUILD)/microhttpd_fileserver_dirs_without_lib_orig.ll: $(BUILD_DIR)/libmicrohttpd_orig.ll
	
	BINARY_FILE="$(MICROHTTPD_FILESERVER_DIRS_ORIG)" \
	OUTPUT_FILE="$@" \
		./extract_llvm_ir.sh