# 
# - Makefile to compile all POSIX applications -
#
# Make sure you have ara-link compiled before you build

SHELL := /bin/bash

# Change this vars to specify another path
MUSL_LIB_C_SRC_PATH = ~/Downloads/musl-1.2.2
BUILD_DIR = ../../build
ARA_LINK = ../../subprojects/ara-link/build/ara-link

POSIX_BUILD = $(BUILD_DIR)/appl/POSIX
OBJ_BUILD = $(POSIX_BUILD)/objs

# Generate list of targets.
# These are all .c files in this dir but with file expansion .ll instead and located in the POSIX build dir.
TARGETS = $(shell (find *.c | cut -f 1 -d '.') | awk '{ print "$(POSIX_BUILD)/" $$0 ".ll" }')

CC = clang
CFLAGS = -g -O0 -S -emit-llvm


all: $(TARGETS)
.PHONY: all

# Link POSIX applications with musl lib c
$(TARGETS): $(POSIX_BUILD)/%.ll : $(OBJ_BUILD)/%.ll $(POSIX_BUILD)/musl_libc.ll
	@mkdir -p $(@D)
	$(ARA_LINK) -S -o $@ $< $(POSIX_BUILD)/musl_libc.ll

# Compile POSIX C files
$(OBJ_BUILD)/%.ll: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -o $@ $<

$(POSIX_BUILD)/musl_libc.ll: build_musl_lib_c_to_llvm_ll.sh
	./build_musl_lib_c_to_llvm_ll.sh $(MUSL_LIB_C_SRC_PATH) $@