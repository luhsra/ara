# 
# - Makefile to compile all POSIX applications (requires GNU Make) -
#
# Make sure you have whole-program-llvm (https://github.com/travitch/whole-program-llvm) installed.
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

# LLVM version to be used. Only required for some systems (see LLVM_SUFFIX)
LLVM_VERSION ?= "10"

# Add here new project names
PROJECT_NAMES = simple_project patric_gbs_a5

# Add here new clean up targets
# All clean up targets will be executed with 'make clean'
CLEAN_UP_TARGETS = clean-patric

# Change this vars to specify another path

# Meson build root directory.
BUILD_ROOT ?= ../../build

# All target and intermediate files will be saved in this directory.
BUILD_DIR ?= $(BUILD_ROOT)/appl/POSIX

# The path to the ARA link utility binary.
ARA_LINK ?= $(BUILD_ROOT)/subprojects/ara-link/ara-link

# The path to the modded musl libc
MUSL_LIB_C_SRC_PATH ?= ../../subprojects/musl-libc

# In this directory are all LLVM IR targets located without the musl libc included.
OBJ_BUILD = $(BUILD_DIR)/objs

# In this directory are all executables located.
BIN_PATH = $(BUILD_DIR)/bin

# Directory of all C files that needs to be added to the musl libc.
ADD_TO_MUSL_LIBC_SRC_DIR = _add_to_musl_libc

# Destination dir for the LLVM IR of all files in ADD_TO_MUSL_LIBC_SRC_DIR
ADD_TO_MUSL_LIBC_DEST_DIR = $(BUILD_DIR)/add_to_musl_libc

# Tools
AWK_TO_TARGET = awk '{ print "$(BUILD_DIR)/" $$0 ".ll" }'
AWK_TO_BIN_TARGET = awk '{ print "$(BIN_PATH)/" $$0 }'
AWK_TO_ADD_TO_MUSL_TARGET = awk '{ print "$(ADD_TO_MUSL_LIBC_DEST_DIR)/" $$0 ".ll" }'

# Creates the dest directory in a rule.
# Just call this var at the beginning of the rule.
CREATE_DEST_DIR = mkdir -p $(@D)

# Function: to_absolute(path)
# Returns the path $(1) as absolute path.
CASE_DO = )
define to_absolute
$(shell case $(1) in \
			/*$(CASE_DO) echo "$(1)" ;; \
			*$(CASE_DO) echo "$$(pwd)/$(1)" ;; \
		esac)
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

# Suffix for all LLVM programs. [the shell executes: <llvm-program>$(LLVM_SUFFIX)]
# If "" not working than choose "-$(LLVM_VERSION)".
LLVM_SUFFIX := $(shell 	if $(call command_availiable_shell,llvm-dis) then \
					   		echo ""; \
						else \
							echo "-$(LLVM_VERSION)"; \
						fi)

LLVM_LLC ?= llc$(LLVM_SUFFIX)
LLVM_OPT ?= opt$(LLVM_SUFFIX)
LLVM_DIS ?= llvm-dis$(LLVM_SUFFIX)

# Make LLVM_DIS callable from build_makefile_app.sh
export LLVM_DIS

# Check dependencies
ifeq ($(call command_availiable,extract-bc), false)
$(info command extract-bc not found!)
$(error wllvm tool (https://github.com/travitch/whole-program-llvm) is not installed! Install via "pip3 install wllvm")
endif

ifeq ($(call command_availiable,$(LLVM_LLC)), false)
$(error command $(LLVM_LLC) not found!)
endif

ifeq ($(call command_availiable,$(LLVM_OPT)), false)
$(error command $(LLVM_OPT) not found!)
endif

ifeq ($(call command_availiable	,$(LLVM_DIS)), false)
$(error command $(LLVM_DIS) not found!)
endif

# Make sure the path is always absolute
MUSL_INSTALL_DIR := $(call to_absolute,$(BUILD_DIR)/musl_install_dir)
MUSL_INCLUDE_DIR := $(MUSL_INSTALL_DIR)/include/

SINGLE_FILE_APPLICATIONS := $(shell find *.c | cut -f 1 -d '.')
ADD_TO_MUSL_LIBC_CODE := $(shell find ./$(ADD_TO_MUSL_LIBC_SRC_DIR)/ -type f -printf "%f\n" | cut -f 1 -d '.')
APPLICATIONS = $(SINGLE_FILE_APPLICATIONS) $(PROJECT_NAMES)

# Generate list of LLVM IR targets.
# These are all .c files in this dir but with file expansion .ll instead and located in the POSIX build dir.
# All project target files described with PROJECT_NAMES will be added to the list of target files.
TARGETS = $(call do_for_all,$(APPLICATIONS),$(AWK_TO_TARGET))

# Generate list of executable targets in BIN_PATH.
# These are all applications in APPLICATIONS (like in TARGETS) but in the BIN_PATH dir.
BIN_TARGETS = $(call do_for_all,$(APPLICATIONS),$(AWK_TO_BIN_TARGET))

# List of all targets that will be added to the musl libc.
# All these targets will be linked with the original musl libc LLVM IR.
ADD_TO_MUSL_LIBC_TARGETS = $(call do_for_all,$(ADD_TO_MUSL_LIBC_CODE),$(AWK_TO_ADD_TO_MUSL_TARGET))

COMPILE_WITH_MUSL_INCLUDE := -isystem$(MUSL_INCLUDE_DIR)
CC = clang
CFLAGS = -g -O0 -Wall -fno-builtin $(COMPILE_WITH_MUSL_INCLUDE)
CFLAGS_TO_EMIT_LLVM = -S -emit-llvm $(CFLAGS)
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
	$(LLVM_LLC) -filetype=obj -o $@.o $<
	@# Add -lgcc to the linkage list if you get linker errors associated with compiler intrinsics.
	$(CC) $(LDFLAGS) $@.o ${MUSL_INSTALL_DIR}/lib/crt1.o ${MUSL_INSTALL_DIR}/lib/libc.a -o $@
	rm $@.o

# Link POSIX applications with musl libc
$(TARGETS): $(BUILD_DIR)/%.ll : $(OBJ_BUILD)/%.ll $(BUILD_DIR)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(ARA_LINK) -S -o $@ $< $(BUILD_DIR)/musl_libc.ll
	@#$(LLVM_OPT) -S -o $@ --dce $@

# Compile simple POSIX C files
$(OBJ_BUILD)/%.ll: %.c $(BUILD_DIR)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS_TO_EMIT_LLVM) -o $@ $<

# Link musl libc with ADD_TO_MUSL_LIBC_TARGETS.
$(BUILD_DIR)/musl_libc.ll: $(OBJ_BUILD)/musl_libc_original.ll $(ADD_TO_MUSL_LIBC_TARGETS)
	$(ARA_LINK) -S -o $@ $^

# Compile ADD_TO_MUSL_LIBC_TARGETS
$(ADD_TO_MUSL_LIBC_TARGETS): $(ADD_TO_MUSL_LIBC_DEST_DIR)/%.ll: $(ADD_TO_MUSL_LIBC_SRC_DIR)/%.c $(OBJ_BUILD)/musl_libc_original.ll
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS_TO_EMIT_LLVM) -o $@ $<

# Build and install musl libc. 
$(OBJ_BUILD)/musl_libc_original.ll: build_makefile_app.sh
	@$(CREATE_DEST_DIR)
	@mkdir -p $(MUSL_INSTALL_DIR)

	@# invoke Makefile with WLLVM.
	@# The environment variables CFLAGS and LDFLAGS are set for the ./configure script.
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