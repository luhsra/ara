autosar_includes = ['-I', meson.current_source_dir() / 'source' / 'os']

autosar_targets = []
foreach app : [['minexample',            'minexample.oil']]
  app_ll = custom_target('autosar-' + app[0],
                         input : app[0] + '.cc',
                         output : 'autosar-' + app[0] + '.ll',
                         depfile : 'autosar-' + app[0] + '.ll.dep',
                         command : clang_cpp +
                                      libs_includes +
                                      ir_flags +
                                      clang_flags)
    set_variable('autosar_' + app[0].underscorify(), [app_ll, files(app[1])])
    autosar_targets += app_ll
endforeach

autosar_examples = run_target('autosar-examples',
                              command: nop,
                              depends: autosar_targets)
