
# Built for GNU make 4.3
# Attention: This script is not working correctly.
#			 If you want to support building of GNU make with musl libc see the notes below.

GNU_MAKE_SRC_PATH = ~/Downloads/make-4.3

PROJECT_NAMES += gnu_make
# Building to binary is not supported: (See the note below)
#BIN_PROJECT_NAMES += gnu_make

$(OBJ_BUILD)/gnu_make.ll: build_makefile_app.sh $(BUILD_DIR)/musl_libc.ll

	@$(CREATE_DEST_DIR)

	@# GNU make is not POSIX compliant. See src/dir.h line 1336 in make-4.3. It uses glob_t->gl_opendir, glob_t->gl_readdir, ...
	@# So we need to compile it with glibc (Suppose that this is the standard library on this system)
	@# Add $(USE_MUSL_CLANG) below if GNU make can be compiled with musl libc.
	@# Currently GNU make will be linked with musl libc but we need to use the glibc here. This leads to inconsistency.
	
	PROJECT_PATH=$(GNU_MAKE_SRC_PATH) \
	BINARY_FILE=$(GNU_MAKE_SRC_PATH)/make \
	OUTPUT_FILE=$@ \
	EXEC_CONFIGURE=true \
	CFLAGS="-g -O0" \
		./build_makefile_app.sh