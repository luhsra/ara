
# run target to invoke POSIX build Makefile (rule: all)
posix_dir = meson.current_source_dir()
cpus = run_command('nproc', '|', 'tr', '-d', '\n').stdout()
run_target('posix',
  command: ['make', '-C', posix_dir, 'BUILD_ROOT=' + meson.build_root(), '-j' + cpus])

# run target to remove POSIX build generated files.
run_target('posix-clean',
  command: ['make', '-C', posix_dir, 'BUILD_ROOT=' + meson.build_root(), 'clean'])

# run target to clear POSIX build directory.
# This is useful if you want to rebuild all POSIX targets without rebuilding the musl libc.
run_target('posix-clean-build-dir',
  command: ['make', '-C', posix_dir, 'BUILD_ROOT=' + meson.build_root(), 'clean-build-dir'])