#!/bin/sh

# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Arguments
readonly PYTHON="$1"
readonly PYTHON_ARA_INSTALL_DIR="$2"
readonly INSTALL_DATA_DIR="$3"

# workaround: copy SVFs ExtAPI.json
# install() in CMake will be ignored by Mesons Cmake module (https://github.com/mesonbuild/meson/issues/10298)
# so we need to install SVFs ExtAPI.json in this project.
# This can not be done in a Meson script because Mesons security concept does not allow accessing files in subprojects directly.
mkdir -p "${MESON_INSTALL_DESTDIR_PREFIX}/${INSTALL_DATA_DIR}/svf"
cp "${MESON_SOURCE_ROOT}/subprojects/svf/include/Util/ExtAPI.json" "${MESON_INSTALL_DESTDIR_PREFIX}/${INSTALL_DATA_DIR}/svf"

# Compile python files
"${PYTHON}" -O -m compileall "${PYTHON_ARA_INSTALL_DIR}" -j 0 -o 0 -o 1 -o 2 --hardlink-dupes
