
# All non musl libc linked llvm files
foreach appl : appl_list
  target_name = 'posix_' + appl
  posix_target = custom_target(target_name,
                            output : [appl + '.ll'],
                            # See custom targets in appl/POSIX/meson.build for more information
                            depends : posix_make_cust_target,
                            command : ['true'])
  set_variable(target_name, posix_target)
endforeach