
posix_src_dir = meson.current_source_dir()
posix_output_dir = meson.current_build_dir()
posix_make_command = ['make', '-C', posix_src_dir, 'BUILD_ROOT=' + meson.build_root(), 'BUILD_DIR=' + posix_output_dir]
cpus = run_command('nproc').stdout().split('\n')[0]

# run target to invoke POSIX build Makefile (rule: all)
run_target('posix',
  command: posix_make_command + ['-j' + cpus])

# run target to remove POSIX build generated files.
run_target('posix-clean',
  command: posix_make_command + ['clean'])

# run target to clear POSIX build directory.
# This is useful if you want to rebuild all POSIX targets without rebuilding the musl libc.
run_target('posix-clean-build-dir',
  command: posix_make_command + ['clean-build-dir'])


# Get targets of Makefile as text files
run_command(posix_make_command + ['get-targets'])
make_musl_targets = run_command('cat', posix_output_dir / 'make_musl_targets.txt').stdout().split()
make_objs_targets = run_command('cat', posix_output_dir / 'make_objs_targets.txt').stdout().split()

# Custom Target to execute the "all" Rule in Makefile.
# This is a workaround to avoid Mesons parallel execution of multiple posix make targets.
posix_make_cust_target = custom_target('posix-make',
          output : ['musl_libc.ll'],
          build_always_stale : true,
          command : posix_make_command + ['-j' + cpus])

# All musl libc linked targets 
foreach target : make_musl_targets
  appl_name = run_command('basename', target).stdout().split('.ll')[0]
  target_name = 'posix_' + appl_name + '_musl'
  posix_target = custom_target(target_name,
                            output : [appl_name + '.ll'],
                              # Sadly, this is not working properly: (Meson executes all Make invocations parallel. We have no switch like is_parallel to deactivate this.)
                              # command : posix_make_command + ['-j' + cpus, target])
                            depends : posix_make_cust_target,
                            command : ['true']) # Do nothing

  set_variable(target_name, posix_target)
endforeach

subdir('objs')