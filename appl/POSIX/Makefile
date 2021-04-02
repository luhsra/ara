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
PROJECT_NAMES = simple_project GNU_make

# Change this vars to specify another path
MUSL_LIB_C_SRC_PATH = ~/Downloads/musl-1.2.2
GNU_MAKE_SRC_PATH = ~/Downloads/make-4.3
BUILD_DIR = ../../build
ARA_LINK = ../../subprojects/ara-link/build/ara-link

POSIX_BUILD = $(BUILD_DIR)/appl/POSIX
OBJ_BUILD = $(POSIX_BUILD)/objs

AWK_TO_TARGET = awk '{ print "$(POSIX_BUILD)/" $$0 ".ll" }'
PROJECT_TARGETS = $(shell (echo $(PROJECT_NAMES) | tr ' ' '\n') | $(AWK_TO_TARGET))

# Generate list of targets.
# These are all .c files in this dir but with file expansion .ll instead and located in the POSIX build dir.
# PROJECT_TARGETS will be added to the list of targets.
TARGETS = $(shell (find *.c | cut -f 1 -d '.') | $(AWK_TO_TARGET)) $(PROJECT_TARGETS)

CC = clang
CFLAGS = -g -O0 -S -emit-llvm
CREATE_DEST_DIR = mkdir -p $(@D)

all: $(TARGETS)

clean:
	rm -r $(POSIX_BUILD)/*

.PHONY: all clean

# Link POSIX applications with musl lib c
$(TARGETS): $(POSIX_BUILD)/%.ll : $(OBJ_BUILD)/%.ll $(POSIX_BUILD)/musl_libc.ll
	@$(CREATE_DEST_DIR)
	$(ARA_LINK) -S -o $@ $< $(POSIX_BUILD)/musl_libc.ll

# Compile simple POSIX C files
$(OBJ_BUILD)/%.ll: %.c
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(POSIX_BUILD)/musl_libc.ll: build_GNU_toolchain_app.sh
	@$(CREATE_DEST_DIR)
	./build_GNU_toolchain_app.sh $(MUSL_LIB_C_SRC_PATH) ${MUSL_LIB_C_SRC_PATH}/lib/libc.so $@


########################################### Custom Project Rules ############################################

# --- simple_project ---

# Link
$(OBJ_BUILD)/simple_project.ll: $(OBJ_BUILD)/simple_project/foo.ll $(OBJ_BUILD)/simple_project/bar.ll
	@$(CREATE_DEST_DIR)
	$(ARA_LINK) -S -o $@ $^

# Compile
$(OBJ_BUILD)/simple_project/%.ll : $(OBJ_BUILD)/simple_project/%.c
	@$(CREATE_DEST_DIR)
	$(CC) $(CFLAGS) -o $@ $<


# --- GNU Make ---
$(OBJ_BUILD)/GNU_make.ll: build_GNU_toolchain_app.sh
	@$(CREATE_DEST_DIR)
	./build_GNU_toolchain_app.sh $(GNU_MAKE_SRC_PATH) $(GNU_MAKE_SRC_PATH)/make $@