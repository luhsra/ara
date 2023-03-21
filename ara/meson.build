# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

subdir('common')
subdir('graph')
subdir('steps')

ara_dir = meson.current_source_dir()

install_subdir(ara_dir, exclude_directories: ['common', 'steps/native', 'graph/cgraph',
                                              # Do not copy __pycache__:
                                              '__pycache__', 'graph/__pycache__', 'os/__pycache__',
                                              'os/posix/__pycache__', 'steps/__pycache__',
                                              'steps/multisse_helper/__pycache__', 'visualization/__pycache__',
                                              'visualization/__pycache__', 'visualization/signal/__pycache__',
                                              'visualization/trace/__pycache__', 'visualization/trace/tracer_api/__pycache__',
                                              'visualization/widgets/__pycache__'],
                        exclude_files: ['meson.build', 'graph/meson.build', 'steps/meson.build'],
                        install_dir: 'python')
