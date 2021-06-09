
# All non musl libc linked targets 
foreach target : make_objs_targets
  appl_name = run_command('basename', target).stdout().split('.ll')[0]
  target_name = 'posix_' + appl_name
  posix_target = custom_target(target_name,
                            output : [appl_name + '.ll'],
                            # See custom targets in appl/POSIX/meson.build for more information
                            depends : posix_make_cust_target,
                            command : ['true'])
  set_variable(target_name, posix_target)
endforeach