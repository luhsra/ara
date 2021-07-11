
# The path to the modded musl libc
MUSL_LIB_C_SRC_PATH ?= ../../subprojects/musl-libc

# Directory of all C files that needs to be added to the musl libc.
ADD_TO_MUSL_LIBC_SRC_DIR = _add_to_musl_libc

# Destination dir for the LLVM IR of all files in ADD_TO_MUSL_LIBC_SRC_DIR
ADD_TO_MUSL_LIBC_DEST_DIR = $(BUILD_DIR)/add_to_musl_libc

# Make sure the path is always absolute
MUSL_INSTALL_DIR := $(shell $(REALPATH) $(BUILD_DIR)/musl_install_dir)
MUSL_INCLUDE_DIR := $(MUSL_INSTALL_DIR)/include/

AWK_TO_ADD_TO_MUSL_TARGET = awk '{ print "$(ADD_TO_MUSL_LIBC_DEST_DIR)/" $$0 ".ll" }'
ADD_TO_MUSL_LIBC_CODE := $(call list_filenames_of_dir,.c,$(ADD_TO_MUSL_LIBC_SRC_DIR))

# List of all targets that will be added to the musl libc.
# All these targets will be linked with the original musl libc LLVM IR.
ADD_TO_MUSL_LIBC_TARGETS = $(call do_for_all,$(ADD_TO_MUSL_LIBC_CODE),$(AWK_TO_ADD_TO_MUSL_TARGET))


# ---- Rules ---- #

# Link musl libc with ADD_TO_MUSL_LIBC_TARGETS.
$(BUILD_DIR)/musl_libc.ll: $(OBJ_BUILD)/musl_libc_original.ll $(ADD_TO_MUSL_LIBC_TARGETS)
	$(LINK_TOGETHER)

# Compile ADD_TO_MUSL_LIBC_TARGETS
$(ADD_TO_MUSL_LIBC_TARGETS): $(ADD_TO_MUSL_LIBC_DEST_DIR)/%.ll: $(ADD_TO_MUSL_LIBC_SRC_DIR)/%.c $(OBJ_BUILD)/musl_libc_original.ll
	$(BUILD_TO_LLVM)

REMOVE_LLVM_BC_ELF_SECTION = objcopy --remove-section .llvm_bc

# Build and install musl libc. 
$(OBJ_BUILD)/musl_libc_original.ll: build_makefile_app.sh
	@$(CREATE_DEST_DIR)
	@mkdir -p $(MUSL_INSTALL_DIR)

	@# invoke Makefile with WLLVM.
	@# The environment variables CFLAGS and LDFLAGS are set for the ./configure script.
	PROJECT_PATH=$(MUSL_LIB_C_SRC_PATH) \
	BINARY_FILE=$(MUSL_LIB_C_SRC_PATH)/lib/libc.a \
	OUTPUT_FILE=$@ \
	EXEC_CONFIGURE=true \
	EXEC_MAKE_RULE="install" \
	CONFIGURE_ARGS="--enable-debug --target=LLVM --build=LLVM --prefix="$(MUSL_INSTALL_DIR)/" --syslibdir="$(MUSL_INSTALL_DIR)/"" \
	CFLAGS="-O0 -fno-builtin" \
	LDFLAGS="-fno-builtin" \
		./build_makefile_app.sh

	@# Remove .llvm_bc section in runtime lib files crt1.o Scrt1.o and rcrt1.o (also in libc.a and libc.so to make sure that nothing is (re)extracting the .bc files)
	@# With the following commands we make sure that WLLVM can not extract the LLVM bitcode of _start_c() or _start().
	@# ARA crashes with custom _start_c or _start symbols.
	$(REMOVE_LLVM_BC_ELF_SECTION) $(MUSL_INSTALL_DIR)/lib/crt1.o
	$(REMOVE_LLVM_BC_ELF_SECTION) $(MUSL_INSTALL_DIR)/lib/Scrt1.o
	$(REMOVE_LLVM_BC_ELF_SECTION) $(MUSL_INSTALL_DIR)/lib/rcrt1.o
	$(REMOVE_LLVM_BC_ELF_SECTION) $(MUSL_INSTALL_DIR)/lib/libc.a
	$(REMOVE_LLVM_BC_ELF_SECTION) $(MUSL_INSTALL_DIR)/lib/libc.so

clean-musl-libc:
	(cd $(MUSL_LIB_C_SRC_PATH) && make clean)
CLEAN_UP_TARGETS += clean-musl-libc