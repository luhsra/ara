
# Builds all CPP_BIN_TARGETS. C++ appl + Libs -> LLVM --> binary
# See llvm_libcxx.mk for more information.

CPP_BIN_TARGETS = $(call do_for_all,$(CPP_BIN_PROJECT_NAMES),$(AWK_TO_BIN_TARGET))

# We need to link with -lgcc and -lgcc_eh to resolve linking errors to C++ intrinsics.
$(CPP_BIN_TARGETS): $(BIN_PATH)/% : $(BUILD_DIR)/%.ll
	@$(CREATE_DEST_DIR)
	$(LLVM_LLC) -filetype=obj -o $@.o $<
	$(CC) $(LDFLAGS_WITH_LLVM_TO_BIN) $@.o $(LINK_WITH_MUSL_BIN) -lgcc -lgcc_eh -fno-use-cxa-atexit -o $@
	$(RM) $@.o

EXTRA_TARGETS += $(CPP_BIN_TARGETS)
#EXTRA_TARGET_NAMES += $(CPP_BIN_PROJECT_NAMES)