# 
# - Makefile to compile all POSIX applications -
#
# Make sure you have whole-program-llvm (https://github.com/travitch/whole-program-llvm) installed.
# Make sure you have ara-link compiled before you build.
# Make sure $(MUSL_LIB_C_SRC_PATH) specifies the correct path to your local Musl Lib-C source dir.
#
# HOW TO:
#
# - add a new single source file application:
# 		Just simply create the file in this directory.
#		The name of the project is the filename.
#
# - add a new complex application: 
#		Write the name of the project in the $(PROJECT_NAMES) list.
#		Create new rules in this Makefile to build the project to a .ll file (without musl lib c linkage).
#
# Note: The destination file for all applications is <project name>.ll in $(POSIX_BUILD)

SHELL := /bin/bash

# Add here new project names
PROJECT_NAMES = simple_project

# Change this vars to specify another path
#MUSL_LIB_C_SRC_PATH = ~/Downloads/musl-1.2.2
MUSL_LIB_C_SRC_PATH = ~/Downloads/musllvm-master
#GNU_MAKE_SRC_PATH = ~/Downloads/make-4.3
BUILD_DIR = ../../build
ARA_LINK = ../../subprojects/ara-link/build/ara-link

POSIX_BUILD = $(BUILD_DIR)/appl/POSIX
OBJ_BUILD = $(POSIX_BUILD)/objs
BIN_PATH = $(POSIX_BUILD)/bin

# Make sure this path is always absolute
MUSL_INSTALL_DIR := $(shell pwd)/$(POSIX_BUILD)/musl_install_dir
MUSL_INCLUDE_DIR := $(MUSL_INSTALL_DIR)/include/

# Tools
TO_LIST = tr ' ' '\n'
AWK_TO_TARGET = awk '{ print "$(POSIX_BUILD)/" $$0 ".ll" }'
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

clean:
	rm -r $(POSIX_BUILD)/*
clean-bin:
	rm -r $(BIN_PATH)

.PHONY: all bin validate ll llvm-ir clean clean-bin

# Create test executables (to validate the correctness of the generated LLVM IR and to display linking errors from applications)
$(BIN_TARGETS): $(BIN_PATH)/% : $(POSIX_BUILD)/%.ll
	@$(CREATE_DEST_DIR)
	llc -filetype=obj -o $@.o $<
	$(CC) $(LDFLAGS) $@.o ${MUSL_INSTALL_DIR}/lib/crt1.o ${MUSL_INSTALL_DIR}/lib/libc.a -lgcc -o $@
	rm $@.o

# Link POSIX applications with musl lib c
$(TARGETS): $(POSIX_BUILD)/%.ll : $(OBJ_BUILD)/%.ll $(POSIX_BUILD)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(ARA_LINK) -S -o $@ $< $(POSIX_BUILD)/musl_libc.ll
	@#opt -S -o $@ --dce $@

# Compile simple POSIX C files
$(OBJ_BUILD)/%.ll: %.c $(POSIX_BUILD)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS_TO_EMIT_LLVM) -o $@ $<

# Build and install musl libc. 
# Get static libc.a in LLVM IR.
$(POSIX_BUILD)/musl_libc.ll: build_GNU_toolchain_app.sh
	@$(CREATE_DEST_DIR)
	@mkdir -p $(MUSL_INSTALL_DIR)
	@# Remove --target=LLVM --build=LLVM if you build with standard musl libc
	CFLAGS="-O0 -fno-builtin" LDFLAGS=-fno-builtin ./build_GNU_toolchain_app.sh $(MUSL_LIB_C_SRC_PATH) ${MUSL_INSTALL_DIR}/lib/libc.a $@ "--enable-debug --target=LLVM --build=LLVM --prefix=$(MUSL_INSTALL_DIR)/" "--linker $(ARA_LINK) --bitcode" true

########################################### Custom Project Rules ############################################

# --- simple_project ---

# Link
$(OBJ_BUILD)/simple_project.ll: $(OBJ_BUILD)/simple_project/foo.ll $(OBJ_BUILD)/simple_project/bar.ll
	@$(CREATE_DEST_DIR)
	$(ARA_LINK) -S -o $@ $^

# Compile
$(OBJ_BUILD)/simple_project/%.ll : $(OBJ_BUILD)/simple_project/%.c $(POSIX_BUILD)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS) -o $@ $<


# --- GNU Make ---
#$(OBJ_BUILD)/GNU_make.ll: build_GNU_toolchain_app.sh $(POSIX_BUILD)/musl_libc.ll
#	@$(CREATE_DEST_DIR)
#	@# GNU make is not POSIX compliant. See src/dir.h line 1336 in make-4.3. It uses glob_t->gl_opendir, glob_t->gl_readdir, ...
#	@# CFLAGS="-g $(COMPILE_WITH_MUSL_INCLUDE)" ./build_GNU_toolchain_app.sh $(GNU_MAKE_SRC_PATH) $(GNU_MAKE_SRC_PATH)/make $@ "" "--linker $(ARA_LINK)" false
#	@# So we need to compile it with GNU libc headers (Suppose that these are the standard headers on this system):
#	@CFLAGS="-g" ./build_GNU_toolchain_app.sh $(GNU_MAKE_SRC_PATH) $(GNU_MAKE_SRC_PATH)/make $@ "" "--linker $(ARA_LINK)" false