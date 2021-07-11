
# Built for version 0.9.73
# Include this script after all applications using libmicrohttpd.

LIBMICROHTTPD_DIR ?= ../../subprojects/libmicrohttpd
LIBMICROHTTPD_DIR := $(shell $(REALPATH) $(LIBMICROHTTPD_DIR))

# Only execute configure if there is no Makefile in $(LIBMICROHTTPD_DIR)
MHD_REBUILD_MAKEFILE := $(shell if [ -e "$(LIBMICROHTTPD_DIR)"/Makefile ]; then \
									echo "false"; \
								else \
									echo "true"; \
								fi)

# A libmicrohttpd demo application module that needs the postprocessor can override this variable.  
DISABLE_POSTPROCESSOR ?= --disable-postprocessor

# Generate autotools configure
$(LIBMICROHTTPD_DIR)/configure:
	$(LIBMICROHTTPD_DIR)/bootstrap

$(BUILD_DIR)/libmicrohttpd.ll: build_makefile_app.sh $(BUILD_DIR)/musl_libc.ll $(LIBMICROHTTPD_DIR)/configure

	@# Invoke Makefile with WLLVM.
	@# The environment variable CFLAGS is set to override CFLAGS in the calling Makefile.
	PROJECT_PATH="$(LIBMICROHTTPD_DIR)" \
	BINARY_FILE="$(LIBMICROHTTPD_DIR)/src/microhttpd/.libs/libmicrohttpd.a" \
	OUTPUT_FILE="$@" \
	EXEC_CONFIGURE="$(MHD_REBUILD_MAKEFILE)" \
	CONFIGURE_ARGS="--disable-nls --enable-https=no --without-gnutls --with-threads=posix --disable-curl --disable-largefile --disable-messages --disable-dauth --disable-httpupgrade --disable-epoll --disable-poll --enable-itc=pipe $(DISABLE_POSTPROCESSOR)" \
	$(USE_MUSL_CLANG) \
	CFLAGS="$(CFLAGS_NO_MUSL_INCL)" \
		./build_makefile_app.sh

clean-libmicrohttpd:
	if [ -e "$(LIBMICROHTTPD_DIR)/Makefile" ] ; then \
		(cd "$(LIBMICROHTTPD_DIR)" && make clean); \
		(cd "$(LIBMICROHTTPD_DIR)" && make distclean); \
	fi
CLEAN_UP_TARGETS += clean-libmicrohttpd