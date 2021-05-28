
# The application to this script is a homework in the course "Grundlagen der Betriebssysteme". (Leibniz Universität Hannover)
# I will not provide my solution here. If you have your own solution go ahead and analyze it.
# It is an interesting example to analyze.

# Set the path to your local solution:
PATRIC_DIR ?= ~/patric_gbs_a5
PATRIC_DIR := $(shell $(REALPATH) $(PATRIC_DIR))

PROJECT_NAMES += patric_gbs_a5
BIN_PROJECT_NAMES += patric_gbs_a5

$(OBJ_BUILD)/patric_gbs_a5.ll: build_makefile_app.sh $(BUILD_DIR)/musl_libc.ll

	@# invoke Makefile with WLLVM.
	@# The environment variable CFLAGS is set to override CFLAGS in the calling Makefile.
	PROJECT_PATH=$(PATRIC_DIR) \
	BINARY_FILE=$(PATRIC_DIR)/patric \
	OUTPUT_FILE=$@ \
	EXEC_CONFIGURE=false \
	MAKE_ARGS="--environment-overrides" \
	$(USE_MUSL_CLANG) \
	CFLAGS="-std=c11 -D_XOPEN_SOURCE=700 -pthread $(CFLAGS_NO_MUSL_INCL)" \
		./build_makefile_app.sh

clean-patric:
	(cd $(PATRIC_DIR) && make clean)
	$(RM) -f $$(find "$(PATRIC_DIR)" -name ".*.bc")
CLEAN_UP_TARGETS += clean-patric