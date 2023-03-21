#!/bin/sh

# Arguments
readonly PYTHON="$1"
readonly REPLACE_IN_TEXTFILE_SCRIPT="$2"

# copy svfs ExtAPI.json
# This can not be done in Meson because Mesons security concept does not allow accessing files in subdirectories directly
mkdir -p "${MESON_INSTALL_DESTDIR_PREFIX}/include/Util/"
cp "${MESON_SOURCE_ROOT}/subprojects/svf/include/Util/ExtAPI.json" "${MESON_INSTALL_DESTDIR_PREFIX}/include/Util/ExtAPI.json"

# Compile python files
"${PYTHON}" -O -m compileall "${MESON_INSTALL_DESTDIR_PREFIX}/python" -j 0 -o 0 -o 1 -o 2 --hardlink-dupes

# Set __ARA_DEFAULT_INSTALL_DIR__ in start scripts and rename these scripts
"${PYTHON}" "${REPLACE_IN_TEXTFILE_SCRIPT}" "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara.sh" "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara" __ARA_DEFAULT_INSTALL_DIR__ "${MESON_INSTALL_DESTDIR_PREFIX}"
"${PYTHON}" "${REPLACE_IN_TEXTFILE_SCRIPT}" "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara-gui.sh" "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara-gui" __ARA_DEFAULT_INSTALL_DIR__ "${MESON_INSTALL_DESTDIR_PREFIX}"
chmod a+x "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara"
chmod a+x "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara-gui"
rm "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara.sh"
rm "${MESON_INSTALL_DESTDIR_PREFIX}/bin/ara-gui.sh"
