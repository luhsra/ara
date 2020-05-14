tools_dir = meson.current_source_dir()

compare_nm = [join_paths(tools_dir, 'compare_nm.py')]
compare_time = [join_paths(tools_dir, 'compare_time.py'), meson.build_root()]
gdb_hw_script = [join_paths(tools_dir, 'gdb_stm32.sh')]
qemu_test_runner = files('qemu_test_runner.py')

if get_option('arch') == 'arm'
  qemu_cmd = files('qemu_stm32.sh')
  gdb_qemu_cmd = files('gdb_qemu_stm32.sh')
else
  qemu_cmd = disabler()
  gdb_qemu_cmd = disabler()
endif

