# SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ara code that is used project wide in graph and steps
# technically it is packaged as a set of headers and a static library

common_dependencies = [llvm_dep, boost_dep]
libcommon = static_library('common',
    'llvm_common.cpp',
    dependencies: common_dependencies
)

common_inc = include_directories('.')
common_cython_inc = meson.current_source_dir()
common_cython_files = files('common/__init__.pxd',
                            'common/cy_helper.pxd',
                            'common/backported_utility.pxd')

common_dep = declare_dependency(link_with: libcommon,
                                dependencies: common_dependencies,
                                include_directories: common_inc)

commondir = meson.current_build_dir()
