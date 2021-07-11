
# Built for libcxx in LLVM 12.0.0
# You need to include an ABI impl. after this module.
# For example: llvm_libcxxabi.
# If you change the ABI update LLVM_LIBCXXABI_INCLUDE.

# TODO: Use $(USE_MUSL_CLANG) to build with musl libc binaries.
#		Currently this is not working because musl-clang is not supporting C++.

# Include the file llvm_libcxx_binary.mk after all C++ application modules.

# --- Library --- #

LLVM_LIBCXX_SRC_PATH ?= ~/Downloads/llvm-project/libcxx
LLVM_LIBCXX_BUILD_DIR ?= $(BUILD_DIR)/llvm_libcxx_build

# Change this directory 
LLVM_LIBCXXABI_INCLUDE ?= $(LLVM_LIBCXX_SRC_PATH)/../libcxxabi/include

# No -nostdinc because the header linux/futex.h is required.
CXXFLAGS_FOR_LIBCXX = $(CFLAGS_NO_MUSL_INCL) -fno-use-cxa-atexit $(COMPILE_WITH_MUSL_INCLUDE)

$(BUILD_DIR)/llvm_libcxx.ll: $(OBJ_BUILD)/llvm_libcxx.ll $(OBJ_BUILD)/llvm_libcxxabi.ll
	$(LINK_TOGETHER)

$(OBJ_BUILD)/llvm_libcxx.ll: $(BUILD_DIR)/musl_libc.ll build_makefile_app.sh
	@$(CREATE_DEST_DIR)
	@mkdir -p "$(LLVM_LIBCXX_BUILD_DIR)"

	cmake -B "$(LLVM_LIBCXX_BUILD_DIR)" -S "$(LLVM_LIBCXX_SRC_PATH)" \
		-DCMAKE_CROSSCOMPILING=True \
		-DCMAKE_C_COMPILER="${WLLVM}" \
		-DCMAKE_CXX_COMPILER="${WLLVM}++" \
		-DLIBCXX_ENABLE_SHARED=OFF \
		-DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
		-DLIBCXX_INCLUDE_BENCHMARKS=OFF \
		-DLIBCXX_ENABLE_EXCEPTIONS=OFF \
		-DLLVM_INCLUDE_TESTS=OFF \
		-DLIBCXX_HAS_MUSL_LIBC=ON \
		-DCMAKE_C_FLAGS="$(CXXFLAGS_FOR_LIBCXX)" \
		-DCMAKE_CXX_FLAGS="$(CXXFLAGS_FOR_LIBCXX)" \
		-DLIBCXX_CXX_ABI=libcxxabi \
        -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$(LLVM_LIBCXXABI_INCLUDE)" \
		-DCMAKE_SYSTEM_INCLUDE_PATH="$(MUSL_INCLUDE_DIR)"
	
	PROJECT_PATH="$(LLVM_LIBCXX_BUILD_DIR)" \
	BINARY_FILE="$(LLVM_LIBCXX_BUILD_DIR)/lib/libc++.a" \
	OUTPUT_FILE=$@ \
	EXEC_CONFIGURE=false \
		./build_makefile_app.sh

# --- C++ appl support --- #

# Includes of the libcxx.
LIBCXX_INCLUDE_DIR := $(LLVM_LIBCXX_BUILD_DIR)/include/c++/v1
COMPILE_WITH_LIBCXX_INCLUDE := -isystem$(LIBCXX_INCLUDE_DIR)

# C++ flags
CXX = clang++
CXXFLAGS = -fno-use-cxa-atexit -g -O0 -Wall -fno-builtin $(COMPILE_WITH_MUSL_INCLUDE) $(COMPILE_WITH_LIBCXX_INCLUDE)
CXXFLAGS_TO_EMIT_LLVM = -S -emit-llvm $(CXXFLAGS)

# Builds the first C++ prerequisite to LLVM IR code.
# The first prerequisite must be .cpp file.
define BUILD_CPP_TO_LLVM
@$(CREATE_DEST_DIR)
$(CXX) $(CXXFLAGS_TO_EMIT_LLVM) -o $@ $<
endef

# C++ project names that will be compiled to binary. [Append in a module]
CPP_BIN_PROJECT_NAMES =