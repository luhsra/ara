
# Built for version 0.9.73

LIBMICROHTTPD_DIR ?= ~/Downloads/embedded_repos/libmicrohttpd-0.9.73
LIBMICROHTTPD_DIR := $(shell $(REALPATH) $(LIBMICROHTTPD_DIR))

$(BUILD_DIR)/libmicrohttpd.ll: build_makefile_app.sh $(BUILD_DIR)/musl_libc.ll

	@# Invoke Makefile with WLLVM.
	@# The environment variable CFLAGS is set to override CFLAGS in the calling Makefile.
	PROJECT_PATH="$(LIBMICROHTTPD_DIR)" \
	BINARY_FILE="$(LIBMICROHTTPD_DIR)/src/microhttpd/.libs/libmicrohttpd.a" \
	OUTPUT_FILE="$@" \
	EXEC_CONFIGURE=true \
	CONFIGURE_ARGS="--disable-nls --enable-https=no --without-gnutls --with-threads=posix" \
	$(USE_MUSL_CLANG) \
	CFLAGS="$(CFLAGS_NO_MUSL_INCL)" \
		./build_makefile_app.sh

clean-libmicrohttpd:
	if [ -e "$(LIBMICROHTTPD_DIR)/Makefile" ] ; then \
		(cd "$(LIBMICROHTTPD_DIR)" && make clean); \
		(cd "$(LIBMICROHTTPD_DIR)" && make distclean); \
	fi
CLEAN_UP_TARGETS += clean-libmicrohttpd