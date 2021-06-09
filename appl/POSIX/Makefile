# 
# - Makefile to compile all POSIX applications (requires GNU Make) -
#
# Make sure you have whole-program-llvm (https://github.com/travitch/whole-program-llvm) installed.
# WARNING: Never ever run this Makefile as root!
# WARNING: Do not create files containing whitespace in this directory
#
# Note: You can safely ignore warnings of type:  WARNING:Could not find ".llvm_bc" ELF section in ...
#		This is the result of assembly source files being processed by wllvm.
#
# HOW TO:
#
# - add a new single source file application:
# 		Just simply create the .c file in this directory or in the $(UNIT_TEST_C_FILES) directory.
#		This script will detect the file automatically.
#		The name of the project is the filename without file extension.
#
# - add a new complex application: 
#		Create a new .mk file in the $(MAKE_INCLUDE_DIR) dir. This is normally ./project_makefiles
#		Append the name of the project in the $(PROJECT_NAMES) list. (As a PROJECT_NAMES += name in the new file)
#		Create new rules in this Makefile to build the project to a .ll file in $(OBJ_BUILD)/ (without musl libc linkage).
#		Musl libc linkage will be applied automatically.
#		Below you find a list of include directives. Add your new file to the list.
#
#		Notes on writing modules for this Makefile:
#			Use the build_makefile_app.sh script to generate LLVM IR of external projects which uses a Makefile to build.
#
#			Write a cleanup .PHONY target to clean object files in an external project directory (Register them in CLEAN_UP_TARGETS).
#			If you want to invoke rm -rf directly, stop. Implement a short check against empty variables beforehand:
#				test -n "$(DIRECTORY)" && $(RM) -rf "$(DIRECTORY)"/*
#
#			To validate the correctness of the generated LLVM IR file it can be useful to compile it to binary.
#			This will detect linking errors and you can check whether the program is runnable.
#			Register your project name in $(BIN_PROJECT_NAMES) to automatically build the LLVM IR to binary.
#
#			See simple_project.mk as a simple example of writing a module.
#
# Note: The destination file for all applications is <project name>.ll in $(BUILD_DIR)

#SHELL := /bin/bash

# LLVM version to be used. Only required for some systems (see LLVM_SUFFIX)
LLVM_VERSION ?= 10

# Change this vars to specify another path

# Meson build root directory.
BUILD_ROOT ?= ../../build

# All target and intermediate files will be saved in this directory.
# Warning: The clean target will delete all files in this dir.
# So make sure to set this var to a dir fully reserved for building with this Makefile.
BUILD_DIR ?= $(BUILD_ROOT)/appl/POSIX

ifeq "$(BUILD_DIR)" ""
$(error BUILD_DIR variable is empty!)
endif

# The path to the ARA link utility binary.
ARA_LINK ?= $(BUILD_ROOT)/subprojects/ara-link/ara-link

# Command to convert a relative path to an absolute one.
# Change this command if you do not have support for realpath on your system.
REALPATH ?= realpath -m

# The path to the directory containing the build-to-LLVM Makefiles for a specific application/project.
MAKE_INCLUDE_DIR = project_makefiles

# In this directory are all LLVM IR targets located without the musl libc included.
OBJ_BUILD = $(BUILD_DIR)/objs

# In this directory are all executables located.
BIN_PATH := $(BUILD_DIR)/bin

# Directory of all unit test C files. All files in this directory are single file applications.
UNIT_TEST_C_FILES = unit_tests

# Tools
AWK_TO_TARGET = awk '{ print "$(BUILD_DIR)/" $$0 ".ll" }'
AWK_TO_BIN_TARGET = awk '{ print "$(BIN_PATH)/" $$0 }'
AWK_TO_OBJS_TARGET = awk '{ print "$(OBJ_BUILD)/" $$0 ".ll" }'

# Creates the dest directory in a rule.
# Just call this var at the beginning of the rule.
CREATE_DEST_DIR = mkdir -p $(@D)

# Links all prerequisites together to the target.
define LINK_TOGETHER
@$(CREATE_DEST_DIR)
$(ARA_LINK) -S -o $@ $^
@#$(LLVM_OPT) -S -o $@ --dce $@
endef

# Builds the first C prerequisite to LLVM IR code.
# The first prerequisite must be .c file.
define BUILD_TO_LLVM
@$(CREATE_DEST_DIR)
$(CC) $(CFLAGS_TO_EMIT_LLVM) -o $@ $<
endef

# Function: do_for_all(list, shell_code) 
# Execute shell code $(2) for all elements in $(1). Delimited by " " or "\n".
define do_for_all
$(shell (echo $(1) | tr ' ' '\n') | $(2))
endef

# Function: command_availiable_shell(command)
# Returns shell failure if the command is not avaliable on the system.
define command_availiable_shell
command -v $(1) > /dev/null;
endef

# Function: command_availiable(command)
# Returns false if the command is not avaliable on the system.
define command_availiable
$(shell if $(call command_availiable_shell,$(1)) then \
			echo "true"; \
		else \
			echo "false"; \
		fi)
endef

# Function: list_filenames_of_dir(filename_extension, dir)
# Returns a list of all files in dir with filename_extension (e.g. ".c")
# Only the filename without the filename_extension will be returned. (e.g. dir/test.c -> test)
define list_filenames_of_dir
$(shell for file in $(2)/*$(1); do \
			echo $$(basename $${file} | cut -f 1 -d '.'); \
		done)
endef

# Suffix for all LLVM programs. [the shell executes: <llvm-program>$(LLVM_SUFFIX)]
# If "" not working than choose "-$(LLVM_VERSION)".
LLVM_SUFFIX := $(shell echo "")
ifeq ($(call command_availiable,llvm-dis), false)
$(warning command llvm-dis not found! Using llvm_suffix -$(LLVM_VERSION) instead.)
LLVM_SUFFIX := -$(LLVM_VERSION)
endif

LLVM_DIS ?= llvm-dis$(LLVM_SUFFIX)
LLVM_LLC ?= llc$(LLVM_SUFFIX)
LLVM_OPT ?= opt$(LLVM_SUFFIX)

# Make LLVM_DIS callable from build_makefile_app.sh
export LLVM_DIS

# Global argument for build_makefile_app.sh
EXTRACT_BC_ARGS = --linker $(ARA_LINK) --bitcode
export EXTRACT_BC_ARGS

export LLVM_COMPILER=clang

# Check dependencies
ifeq ($(call command_availiable,extract-bc), false)
$(info command extract-bc not found!)
$(error wllvm tool (https://github.com/travitch/whole-program-llvm) is not installed! Install via "pip3 install wllvm")
endif

ifeq ($(call command_availiable,$(LLVM_DIS)), false)
$(error command $(LLVM_DIS) not found!)
endif

ifeq ($(call command_availiable,$(LLVM_LLC)), false)
$(error command $(LLVM_LLC) not found!)
endif

ifeq ($(call command_availiable,$(LLVM_OPT)), false)
$(error command $(LLVM_OPT) not found!)
endif

ifeq ($(call command_availiable,$(ARA_LINK)), false)
$(error command $(ARA_LINK) not found!)
endif

ifeq ($(call command_availiable,$(REALPATH)), false)
$(error command $(REALPATH) not found!)
endif

SINGLE_FILE_APPLICATIONS := $(call list_filenames_of_dir,.c,.) $(call list_filenames_of_dir,.c,$(UNIT_TEST_C_FILES))

_default_rule: all

# Be careful with the rm command!
# If you remove files from a directory do a check for empty variables.
# E.g. test -n "$(DIRECTORY)" && $(RM) -rf "$(DIRECTORY)"/*
RM = rm --preserve-root=all

# Project names to build [Append in a module]
PROJECT_NAMES =

# Project names that will be compiled to binary. [Append in a module]
BIN_PROJECT_NAMES =

# Clean up targets. [Append in a module]
# All clean up targets will be executed with 'make clean'
CLEAN_UP_TARGETS =

# Extra targets to build in rule "all". [Append in a module]
EXTRA_TARGETS =

# Include Musl libc module
include $(MAKE_INCLUDE_DIR)/musl_libc.mk

COMPILE_WITH_MUSL_INCLUDE := -isystem$(MUSL_INCLUDE_DIR)

# Generates an argument to WLLVM for build_makefile_app.sh or another direct build system call (e.g. cmake).
# This argument sets the compiler of wllvm to musl-clang instead of clang.
# With musl-clang we can use the musl libc in a complex build process during linking phase.
USE_MUSL_CLANG := LLVM_COMPILER_PATH="$(MUSL_INSTALL_DIR)/bin"

CC = clang
CFLAGS_NO_MUSL_INCL = -g -O0 -Wall -fno-builtin -Wno-unused-command-line-argument
CFLAGS := $(CFLAGS_NO_MUSL_INCL) -nostdinc $(COMPILE_WITH_MUSL_INCLUDE)
CFLAGS_TO_EMIT_LLVM := -S -emit-llvm $(CFLAGS)

LINK_WITH_MUSL_BIN := $(MUSL_INSTALL_DIR)/lib/crt1.o $(MUSL_INSTALL_DIR)/lib/libc.a
LDFLAGS_WITH_LLVM_TO_BIN = -static -nostdlib

# --- Module include --- #

# Fully working modules
include $(MAKE_INCLUDE_DIR)/simple_project.mk
#include $(MAKE_INCLUDE_DIR)/patric_gbs_a5.mk
include $(MAKE_INCLUDE_DIR)/libmicrohttpd.mk
include $(MAKE_INCLUDE_DIR)/microhttpd_demo.mk

# C++ Test
#include $(MAKE_INCLUDE_DIR)/llvm_libcxx.mk
#include $(MAKE_INCLUDE_DIR)/llvm_libcxxabi.mk
#include $(MAKE_INCLUDE_DIR)/cpp_test.mk
#include $(MAKE_INCLUDE_DIR)/llvm_libcxx_binary.mk

# Not working modules
#include $(MAKE_INCLUDE_DIR)/gnu_make.mk
#include $(MAKE_INCLUDE_DIR)/pulse_audio.mk

# Generate list of LLVM IR targets.
# These are all .c files in this dir but with file expansion .ll instead and located in the POSIX build dir.
# All project target files described with PROJECT_NAMES will be added to the list of target files.
TARGETS = $(call do_for_all,$(SINGLE_FILE_APPLICATIONS) $(PROJECT_NAMES),$(AWK_TO_TARGET))

# Generate list of executable targets in BIN_PATH.
# These are all binaries with the names in SINGLE_FILE_APPLICATIONS or BIN_PROJECT_NAMES.
BIN_TARGETS = $(call do_for_all,$(SINGLE_FILE_APPLICATIONS) $(BIN_PROJECT_NAMES),$(AWK_TO_BIN_TARGET))

# Build everything (LLVM IR + Binary files)
all: $(TARGETS) $(BIN_TARGETS) $(EXTRA_TARGETS)

bin: $(BIN_TARGETS)
extra: $(EXTRA_TARGETS)
validate: bin

# Build only LLVM IR
ll: $(TARGETS)
llvm-ir: ll

# Write all targets in the files $(BUILD_DIR)/make_musl_targets.txt [with musl] and $(BUILD_DIR)/make_objs_targets.txt [without musl]
# This is required to provide the targets to Meson.
get-targets:
	@$(CREATE_DEST_DIR)
	@(echo "$(TARGETS) $(EXTRA_TARGETS)" | tr ' ' '\n') > $(BUILD_DIR)/make_musl_targets.txt
	@(echo "$(call do_for_all,$(SINGLE_FILE_APPLICATIONS) $(PROJECT_NAMES),$(AWK_TO_OBJS_TARGET))" | tr ' ' '\n') > $(BUILD_DIR)/make_objs_targets.txt

clean: clean-build-dir $(CLEAN_UP_TARGETS)

clean-build-dir:
	test -n "$(BUILD_DIR)" && $(RM) -rf "$(BUILD_DIR)"/*
clean-bin:
	test -n "$(BIN_PATH)" && $(RM) -rf "$(BIN_PATH)"

.PHONY: _default_rule all bin extra validate ll llvm-ir get-targets clean clean-bin clean-build-dir $(CLEAN_UP_TARGETS)

# Create test executables (to validate the correctness of the generated LLVM IR and to display linking errors from applications)
$(BIN_TARGETS): $(BIN_PATH)/% : $(BUILD_DIR)/%.ll
	@$(CREATE_DEST_DIR)
	$(LLVM_LLC) -filetype=obj -o $@.o $<
	@# Add -lgcc to the linkage list if you get linker errors associated with compiler intrinsics.
	$(CC) $(LDFLAGS_WITH_LLVM_TO_BIN) $@.o $(LINK_WITH_MUSL_BIN) -o $@
	$(RM) $@.o

# Link all POSIX applications with musl libc
$(TARGETS): $(BUILD_DIR)/%.ll : $(OBJ_BUILD)/%.ll $(BUILD_DIR)/musl_libc.ll
	$(LINK_TOGETHER)

# Compile simple POSIX C files (single file applications)
$(OBJ_BUILD)/%.ll: %.c $(BUILD_DIR)/musl_libc.ll
	$(BUILD_TO_LLVM)
$(OBJ_BUILD)/%.ll: $(UNIT_TEST_C_FILES)/%.c $(BUILD_DIR)/musl_libc.ll
	$(BUILD_TO_LLVM)