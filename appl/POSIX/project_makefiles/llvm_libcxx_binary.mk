
# Builds all CPP_BIN_TARGETS. C++ appl + Libs -> LLVM --> binary
# See llvm_libcxx.mk for more information.

CPP_BIN_TARGETS = $(call do_for_all,$(CPP_BIN_PROJECT_NAMES),$(AWK_TO_BIN_TARGET))

# We need to link with -lgcc and -lgcc_eh to resolve linking errors to C++ intrinsics.
$(CPP_BIN_TARGETS): $(BIN_PATH)/% : $(BUILD_DIR)/%.ll
	@$(CREATE_DEST_DIR)
	$(LLVM_LLC) -filetype=obj -o $@.o $<
	$(CC) $(LDFLAGS) $@.o $(MUSL_LIB_C_SRC_PATH)/lib/crt1.o $(MUSL_LIB_C_SRC_PATH)/lib/libc.a -lgcc -lgcc_eh -fno-use-cxa-atexit -o $@
	$(RM) $@.o

EXTRA_TARGETS += $(CPP_BIN_TARGETS)