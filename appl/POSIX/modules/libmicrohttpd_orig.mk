
# Copy of libmicrohttpd.mk but for building the unmodified original version
# Built for version 0.9.73
# Include this script after all applications using libmicrohttpd.

LIBMICROHTTPD_DIR_ORIG ?= ../../subprojects/libmicrohttpd_orig
LIBMICROHTTPD_DIR_ORIG := $(shell $(REALPATH) $(LIBMICROHTTPD_DIR_ORIG))

# Only execute configure if there is no Makefile in $(LIBMICROHTTPD_DIR_ORIG)
MHD_REBUILD_MAKEFILE_ORIG := $(shell if [ -e "$(LIBMICROHTTPD_DIR_ORIG)"/Makefile ]; then \
									echo "false"; \
								else \
									echo "true"; \
								fi)

# A libmicrohttpd demo application module that needs the postprocessor can override this variable.  
DISABLE_POSTPROCESSOR_ORIG ?= --disable-postprocessor

# Generate autotools configure
$(LIBMICROHTTPD_DIR_ORIG)/configure:
	$(LIBMICROHTTPD_DIR_ORIG)/bootstrap

$(BUILD_DIR)/libmicrohttpd_orig.ll: build_makefile_app.sh $(BUILD_DIR)/musl_libc.ll $(LIBMICROHTTPD_DIR_ORIG)/configure

	@# Invoke Makefile with WLLVM.
	@# The environment variable CFLAGS is set to override CFLAGS in the calling Makefile.
	PROJECT_PATH="$(LIBMICROHTTPD_DIR_ORIG)" \
	BINARY_FILE="$(LIBMICROHTTPD_DIR_ORIG)/src/microhttpd/.libs/libmicrohttpd.a" \
	OUTPUT_FILE="$@" \
	EXEC_CONFIGURE="$(MHD_REBUILD_MAKEFILE_ORIG)" \
	CONFIGURE_ARGS="--disable-nls --enable-https=no --without-gnutls --with-threads=posix --disable-curl --disable-largefile --disable-messages --disable-dauth --disable-httpupgrade --disable-epoll --disable-poll --enable-itc=pipe $(DISABLE_POSTPROCESSOR_ORIG)" \
	$(USE_MUSL_CLANG) \
	CFLAGS="$(CFLAGS_NO_MUSL_INCL)" \
		./build_makefile_app.sh

clean-libmicrohttpd-orig:
	if [ -e "$(LIBMICROHTTPD_DIR_ORIG)/Makefile" ] ; then \
		(cd "$(LIBMICROHTTPD_DIR_ORIG)" && make clean); \
		(cd "$(LIBMICROHTTPD_DIR_ORIG)" && make distclean); \
	fi
CLEAN_UP_TARGETS += clean-libmicrohttpd-orig