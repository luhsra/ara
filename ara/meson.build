# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

subdir('common')
subdir('graph')
subdir('steps')

ara_dir = meson.current_source_dir()

# Install python modules
# If this code leads to problems on your system and you do need to install ARA
# just comment out this code. It is only used for installation.
all_ara_files = run_command([py3_inst.full_path(), get_all_ara_python_files],
                            capture: true,
                            check: true)
foreach module_info : all_ara_files.stdout().split()
  module_info = module_info.split(':')
  py3_inst.install_sources(module_info[0],
                           subdir: module_info[1])
endforeach
