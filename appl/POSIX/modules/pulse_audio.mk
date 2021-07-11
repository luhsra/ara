
# Built for PulseAudio 14.2
# Attention: This module is not working correctly. See notes below
# TODO: Use $(USE_MUSL_CLANG) during build process.
#		Currently this leads to the error:
#			Has header "atomic_ops.h" : NO 
#			meson.build:525:2: ERROR: Assert failed: Need libatomic_ops
#		This header is missing in musl libc.

# TODO: change this var
PULSE_AUDIO_SRC_DIR ?= $(shell $(REALPATH) ~/Downloads/pulseaudio)
PULSE_AUDIO_BUILD_DIR ?= $(BUILD_DIR)/pulse_audio_build

PROJECT_NAMES += pulse_audio
# No bin target because it will throw linking errors.

# Add $(OBJ_BUILD)/pulse_audio_common.ll as prerequisite if the rule below is working.
# Note: There are also third party libraries missing. 
$(OBJ_BUILD)/pulse_audio.ll: $(OBJ_BUILD)/pulse_audio_lib.ll $(OBJ_BUILD)/pulse_audio_core.ll $(OBJ_BUILD)/pulse_audio_daemon.ll
	$(LINK_TOGETHER)

# Do not build the following target because of the unresolved error: Linking globals named 'table': symbol multiply defined!
#$(OBJ_BUILD)/pulse_audio_common.ll: $(OBJ_BUILD)/pulse_audio_daemon.ll $(BUILD_DIR)/musl_libc.ll
#BINARY_FILE=$(PULSE_AUDIO_BUILD_DIR)/src/libpulsecommon-14.2.so \
#OUTPUT_FILE=$@ \
#./extract_llvm_ir.sh

$(OBJ_BUILD)/pulse_audio_lib.ll: $(OBJ_BUILD)/pulse_audio_daemon.ll $(BUILD_DIR)/musl_libc.ll

	BINARY_FILE=$(PULSE_AUDIO_BUILD_DIR)/src/pulse/libpulse.so.0.23.0 \
	OUTPUT_FILE=$@ \
		./extract_llvm_ir.sh

$(OBJ_BUILD)/pulse_audio_core.ll: $(OBJ_BUILD)/pulse_audio_daemon.ll $(BUILD_DIR)/musl_libc.ll

	BINARY_FILE=$(PULSE_AUDIO_BUILD_DIR)/src/pulsecore/libpulsecore-14.2.so \
	OUTPUT_FILE=$@ \
		./extract_llvm_ir.sh

$(OBJ_BUILD)/pulse_audio_daemon.ll: $(BUILD_DIR)/musl_libc.ll

	@# Note: we build pulseaudio with Compiler intrinsics.
	@# With the "-fno-builtin" flag the compile process throws lots of errors. 
	(cd "$(PULSE_AUDIO_SRC_DIR)" && \
		CC=wllvm \
		CXX=wllvm++ \
		CFLAGS="-g -O0 -DNDEBUG" \
		CXXFLAGS="-g -O0 -DNDEBUG" \
			meson $(PULSE_AUDIO_BUILD_DIR) -Dtests=false -Dadrian-aec=false --prefix=$(MUSL_INCLUDE_DIR) --includedir=$(MUSL_INCLUDE_DIR) \
	)
	meson compile -C $(PULSE_AUDIO_BUILD_DIR)

	BINARY_FILE=$(PULSE_AUDIO_BUILD_DIR)/src/daemon/pulseaudio \
	OUTPUT_FILE=$@ \
		./extract_llvm_ir.sh