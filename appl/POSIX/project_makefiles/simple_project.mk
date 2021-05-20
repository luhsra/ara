
PROJECT_NAMES += simple_project
BIN_PROJECT_NAMES += simple_project

# Link
$(OBJ_BUILD)/simple_project.ll: $(OBJ_BUILD)/simple_project/foo.ll $(OBJ_BUILD)/simple_project/bar.ll
	$(LINK_TOGETHER)

# Compile
$(OBJ_BUILD)/simple_project/%.ll : $(OBJ_BUILD)/simple_project/%.c $(BUILD_DIR)/musl_libc.ll
	$(BUILD_TO_LLVM)
