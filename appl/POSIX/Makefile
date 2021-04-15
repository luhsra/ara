# 
# - Makefile to compile all POSIX applications (requires GNU Make) -
#
# Make sure you have whole-program-llvm (https://github.com/travitch/whole-program-llvm) installed.
# Make sure you have ara-link compiled before you build.
# Make sure $(MUSL_LIB_C_SRC_PATH) specifies the correct path to your local Musl Lib-C source dir.
#
#
# HOW TO:
#
# - add a new single source file application:
# 		Just simply create the file in this directory.
#		The name of the project is the filename.
#
# - add a new complex application: 
#		Write the name of the project in the $(PROJECT_NAMES) list.
#		Create new rules in this Makefile to build the project to a .ll file (without musl libc linkage).
#		Musl libc linkage and binary generation will be applied automatically.
#		Use the build_makefile_app.sh script to generate LLVM IR of external projects which uses a Makefile to build.
#		Write a cleanup .PHONY target to clean object files in the external project directory (Register them in CLEAN_UP_TARGETS).
#
# Note: The destination file for all applications is <project name>.ll in $(BUILD_DIR)

#SHELL := /bin/bash

# Add here new project names
PROJECT_NAMES = simple_project patric_gbs_a5

# Add here new clean up targets
# All clean up targets will be executed with 'make clean'
CLEAN_UP_TARGETS = clean-patric

# Change this vars to specify another path

#MUSL_LIB_C_SRC_PATH = ~/Downloads/musl-1.2.2
MUSL_LIB_C_SRC_PATH = ~/Downloads/musllvm
#GNU_MAKE_SRC_PATH = ~/Downloads/make-4.3

# All target and intermediate files will be saved in this directory.
BUILD_DIR = ../../build/appl/POSIX

# In this directory are all LLVM IR targets located without the musl libc included.
OBJ_BUILD = $(BUILD_DIR)/objs

# In this directory are all executables located.
BIN_PATH = $(BUILD_DIR)/bin

# The path to the ARA link utility.
ARA_LINK = ../../subprojects/ara-link/build/ara-link

# Make sure this path is always absolute
MUSL_INSTALL_DIR := $(shell pwd)/$(BUILD_DIR)/musl_install_dir
MUSL_INCLUDE_DIR := $(MUSL_INSTALL_DIR)/include/

# Tools
TO_LIST = tr ' ' '\n'
AWK_TO_TARGET = awk '{ print "$(BUILD_DIR)/" $$0 ".ll" }'
AWK_TO_BIN_TARGET = awk '{ print "$(BIN_PATH)/" $$0 }'
CREATE_DEST_DIR = mkdir -p $(@D)

SINGLE_FILE_APPL := $(shell find *.c | cut -f 1 -d '.')
APPLICATIONS = $(SINGLE_FILE_APPL) $(PROJECT_NAMES)

# Generate list of LLVM IR targets.
# These are all .c files in this dir but with file expansion .ll instead and located in the POSIX build dir.
# All project target files described with PROJECT_NAMES will be added to the list of target files.
TARGETS = $(shell (echo $(APPLICATIONS) | $(TO_LIST)) | $(AWK_TO_TARGET))

# Generate list of executable targets in BIN_PATH.
# These are all applications in APPLICATIONS (like in TARGETS) but in the BIN_PATH dir.
BIN_TARGETS = $(shell (echo $(APPLICATIONS) | $(TO_LIST)) | $(AWK_TO_BIN_TARGET))

COMPILE_WITH_MUSL_INCLUDE := -isystem$(MUSL_INCLUDE_DIR)
CC = clang
#CFLAGS = -g -O0 -Wall -fno-builtin -nobuiltininc $(COMPILE_WITH_MUSL_INCLUDE)
CFLAGS = -g -O0 -Wall $(COMPILE_WITH_MUSL_INCLUDE)
CFLAGS_TO_EMIT_LLVM = -S -emit-llvm $(CFLAGS)
#LDFLAGS = -static -nostdlib --no-undefined
LDFLAGS = -static -nostdlib

# Build everything (LLVM IR + Binary files)
all: $(TARGETS) $(BIN_TARGETS)
bin: $(BIN_TARGETS)
validate: bin

# Build only LLVM IR (Use these .PHONY targets if you encounter strange errors with the 'all' target)
ll: $(TARGETS)
llvm-ir: ll

clean: clean-build-dir clean-musl-libc $(CLEAN_UP_TARGETS)

clean-musl-libc:
	(cd $(MUSL_LIB_C_SRC_PATH) && make clean)
clean-build-dir:
	rm -f -r $(BUILD_DIR)/*
clean-bin:
	rm -f -r $(BIN_PATH)

.PHONY: all bin validate ll llvm-ir clean clean-bin clean-build-dir clean-musl-libc $(CLEAN_UP_TARGETS)

# Create test executables (to validate the correctness of the generated LLVM IR and to display linking errors from applications)
$(BIN_TARGETS): $(BIN_PATH)/% : $(BUILD_DIR)/%.ll
	@$(CREATE_DEST_DIR)
	llc -filetype=obj -o $@.o $<
	$(CC) $(LDFLAGS) $@.o ${MUSL_INSTALL_DIR}/lib/crt1.o ${MUSL_INSTALL_DIR}/lib/libc.a -lgcc -o $@
	rm $@.o

# Link POSIX applications with musl lib c
$(TARGETS): $(BUILD_DIR)/%.ll : $(OBJ_BUILD)/%.ll $(BUILD_DIR)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(ARA_LINK) -S -o $@ $< $(BUILD_DIR)/musl_libc.ll
	@#opt -S -o $@ --dce $@

# Compile simple POSIX C files
$(OBJ_BUILD)/%.ll: %.c $(BUILD_DIR)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS_TO_EMIT_LLVM) -o $@ $<

# Build and install musl libc. 
# Get static libc.a in LLVM IR.
$(BUILD_DIR)/musl_libc.ll: build_makefile_app.sh
	@$(CREATE_DEST_DIR)
	@mkdir -p $(MUSL_INSTALL_DIR)

	@# invoke Makefile with WLLVM.
	@# The environment variables CFLAGS and LDFLAGS are set for the ./configure script.
	@# Remove "--target=LLVM --build=LLVM" in CONFIGURE_ARGS if you build with standard musl libc
	PROJECT_PATH=$(MUSL_LIB_C_SRC_PATH) \
	BINARY_FILE=${MUSL_INSTALL_DIR}/lib/libc.a \
	OUTPUT_FILE=$@ \
	EXEC_CONFIGURE=true \
	EXEC_MAKE_INSTALL=true \
	CONFIGURE_ARGS="--enable-debug --target=LLVM --build=LLVM --prefix=$(MUSL_INSTALL_DIR)/" \
	EXTRACT_BC_ARGS="--linker $(ARA_LINK) --bitcode" \
	CFLAGS="-O0 -fno-builtin" \
	LDFLAGS="-fno-builtin" \
		./build_makefile_app.sh

########################################### Custom Project Rules ############################################

# --- simple_project ---

# Link
$(OBJ_BUILD)/simple_project.ll: $(OBJ_BUILD)/simple_project/foo.ll $(OBJ_BUILD)/simple_project/bar.ll
	@$(CREATE_DEST_DIR)
	$(ARA_LINK) -S -o $@ $^

# Compile
$(OBJ_BUILD)/simple_project/%.ll : $(OBJ_BUILD)/simple_project/%.c $(BUILD_DIR)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS) -o $@ $<


# --- patric_gbs_a5 ---
PATRIC_DIR = ./patric_gbs_a5
$(OBJ_BUILD)/patric_gbs_a5.ll: build_makefile_app.sh $(BUILD_DIR)/musl_libc.ll

	@# invoke Makefile with WLLVM.
	@# The environment variable CFLAGS is set to override CFLAGS in the calling Makefile.
	PROJECT_PATH=$(PATRIC_DIR) \
	BINARY_FILE=$(PATRIC_DIR)/patric \
	OUTPUT_FILE=$@ \
	EXEC_CONFIGURE=false \
	EXEC_MAKE_INSTALL=false \
	MAKE_ARGS="--environment-overrides" \
	EXTRACT_BC_ARGS="--linker $(ARA_LINK) --bitcode" \
	CFLAGS="-std=c11 -Wall -Werror -pedantic -D_XOPEN_SOURCE=700 -pthread -g -O0 $(COMPILE_WITH_MUSL_INCLUDE)" \
		./build_makefile_app.sh

clean-patric:
	(cd $(PATRIC_DIR) && make clean)
	rm -f $$(find "$(PATRIC_DIR)" -name ".*.bc")

# --- GNU Make ---
#$(OBJ_BUILD)/GNU_make.ll: build_GNU_toolchain_app.sh $(BUILD_DIR)/musl_libc.ll
#	@$(CREATE_DEST_DIR)
#	@# GNU make is not POSIX compliant. See src/dir.h line 1336 in make-4.3. It uses glob_t->gl_opendir, glob_t->gl_readdir, ...
#	@# CFLAGS="-g $(COMPILE_WITH_MUSL_INCLUDE)" ./build_GNU_toolchain_app.sh $(GNU_MAKE_SRC_PATH) $(GNU_MAKE_SRC_PATH)/make $@ "" "--linker $(ARA_LINK)" false
#	@# So we need to compile it with GNU libc headers (Suppose that these are the standard headers on this system):
#	@CFLAGS="-g" ./build_GNU_toolchain_app.sh $(GNU_MAKE_SRC_PATH) $(GNU_MAKE_SRC_PATH)/make $@ "" "--linker $(ARA_LINK)" false