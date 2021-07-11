
# This module builds cpp_test.cpp
# include llvm_libcxx.mk and an ABI impl. like llvm_libcxxabi.mk before this script. 

PROJECT_NAMES += cpp_test
CPP_BIN_PROJECT_NAMES += cpp_test

# Link
$(OBJ_BUILD)/cpp_test.ll: $(OBJ_BUILD)/cpp_test_without_libcxx.ll $(BUILD_DIR)/llvm_libcxx.ll
	$(LINK_TOGETHER)

# Compile
$(OBJ_BUILD)/cpp_test_without_libcxx.ll: cpp_test.cpp $(BUILD_DIR)/llvm_libcxx.ll
	$(BUILD_CPP_TO_LLVM)