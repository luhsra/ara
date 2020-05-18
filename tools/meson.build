tools_dir = meson.current_source_dir()

compare_nm = files('compare_nm.py')
compare_time = files('compare_time.py')
gdb_hw_script = files('gdb_stm32.sh')
qemu_test_runner = files('qemu_test_runner.py')
dump_cmds = files('dump_cmds.py')
gcc_version = files('gcc_version.py') # drop, when https://github.com/mesonbuild/meson/issues/7166 is resolved

if get_option('arch') == 'arm'
  qemu_cmd = files('qemu_stm32.sh')
  gdb_qemu_cmd = files('gdb_qemu_stm32.sh')
else
  qemu_cmd = disabler()
  gdb_qemu_cmd = disabler()
endif

