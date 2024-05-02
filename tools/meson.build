# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2023 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

tools_dir = meson.current_source_dir()

compare_nm = files('compare_nm.py')
compare_time = files('compare_time.py')
gdb_hw_script = files('gdb_stm32.sh')
qemu_test_runner = files('qemu_test_runner.py')
validate_generator_runner = files('validate_generator_runner.py')
dump_cmds = files('dump_cmds.py')
ctimeout = files('ctimeout')
get_all_ara_python_files = files('get_all_ara_python_files.py')

qemu_cmd = disabler()
gdb_qemu_cmd = disabler()

if arm_enabled
  qemu = find_program('qemu-system-stm32', required: false)
  if qemu.found()
    # TODO qemu_stm32.sh uses qemu-system-stm32 internally. Use always the binary provided by Meson
    # TODO port qemu_stm32 to Python
    qemu_cmd = files('qemu_stm32.sh')
    gdb_qemu_cmd = files('gdb_qemu_stm32.sh')
  endif
endif

#riscv
if true
  qemu = find_program('qemu-system-riscv32', required: false)
  if qemu.found()
    # TODO qemu_stm32.sh uses qemu-system-stm32 internally. Use always the binary provided by Meson
    # TODO port qemu_stm32 to Python
    qemu_cmd = files('qemu_stm32.sh')
    gdb_qemu_cmd = files('gdb_qemu_stm32.sh')
  endif
endif

meson.add_install_script('post_meson_install.sh', py3_inst.path(),
                         py3_inst.get_install_dir() / 'ara',
                         get_option('datadir'))
