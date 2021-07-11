
# This file handles unit tests that should not be linked with the musl libc

NO_MUSL_LINKAGE_DIR = $(TEST_C_FILES)/no_musl_linkage

NO_MUSL_LINKAGE_NAMES = $(call list_filenames_of_dir,.c,$(NO_MUSL_LINKAGE_DIR))
NO_MUSL_LINKAGE_TARGETS = $(call do_for_all,$(NO_MUSL_LINKAGE_NAMES),$(AWK_TO_OBJS_TARGET))

$(NO_MUSL_LINKAGE_TARGETS): $(OBJ_BUILD)/%.ll : $(NO_MUSL_LINKAGE_DIR)/%.c $(BUILD_DIR)/musl_libc.ll
	$(BUILD_TO_LLVM)

EXTRA_TARGETS += $(NO_MUSL_LINKAGE_TARGETS)
EXTRA_TARGET_NAMES += $(NO_MUSL_LINKAGE_NAMES)