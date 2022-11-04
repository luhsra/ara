
posix_src_dir = meson.current_source_dir()
posix_output_dir = meson.current_build_dir()
posix_make_command = ['make', '-C', posix_src_dir,
                      'BUILD_ROOT=' + meson.build_root(),
                      'BUILD_DIR=' + posix_output_dir, 
                      'ARA_LINK=' + ara_link.full_path(),
                      'CLANG=' + clang.full_path(),
                      'LLVM_DIS=' + llvm_dis.full_path(),
                      'LLVM_LLC=' + llc.full_path(),
                      'LLVM_OPT=' + llvm_opt.full_path(),
                      'WLLVM=' + wllvm.full_path(),
                      'EXTRACT_BC=' + extract_bc.full_path(),
                      'REALPATH=' + realpath.full_path()]
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


# Get all target applications of Makefile
appl_list = run_command('cat', posix_src_dir / 'appl_list.txt').stdout().split()

# Custom Target to execute the "all" Rule in Makefile.
# This is a workaround to avoid Mesons parallel execution of multiple posix make targets.
posix_make_cust_target = custom_target('posix-make',
          output : ['musl_libc.ll'], # This output is irrelevant. We set build_always_stale to always execute the Makefile.
          depends: ara_link,
          build_always_stale : true,
          command : posix_make_command + ['-j' + cpus])

# All musl libc linked llvm files 
foreach appl : appl_list
  target_name = 'posix_' + appl + '_musl'
  posix_target = custom_target(target_name,
                            output : [appl + '.ll'],
                              # Sadly, this is not working properly: (Meson executes all Make invocations parallel. We have no switch like is_parallel to deactivate this.)
                              # command : posix_make_command + ['-j' + cpus, target])
                            depends : posix_make_cust_target,
                            command : ['true']) # Do nothing

  set_variable(target_name, posix_target)
endforeach

subdir('objs')