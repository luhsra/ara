benchmark_gen = files('benchmark_gen.py')

full_name = 'synthetic'
# sys, oil = custom_target('autosar_multicore_dynamic_' + seed,
#                          input: [],
#                          output: ['system_' + seed + '.cc', 'system_' + seed + '.json'],
#                          command: [py3, generator, '--oil', '@OUTPUT1@',
#                                    '--system', '@OUTPUT1@',
#                                    '--seed', seed],
#                         )
app_ll =  custom_target(full_name,
                        input : 'synthetic.cc',
                        output : full_name + '.ll',
                        depfile : full_name + '.ll.dep',
                        command : clang_cpp +
                                  libs_includes +
                                  ir_flags +
                                  clang_flags)
app = {'ll': app_ll, 'oil': files('synthetic.oil'), 'sys_timings': 'BB'}

step_data = custom_target(full_name + '.multisse.no_timing.stepdata.json',
                          input: [ara_py, app['ll'], app['oil']],
                          output: full_name + '.multisse.no_timing.stepdata.json',
                          depfile: full_name + '.dep',
                          command: [py3_inst, ara_py, app['ll'],
                                    '--dependency_file', '@DEPFILE@',
                                    '--oilfile', app['oil'],
                                    '-s', 'LockElision', '-s', 'IPIAvoidance',
                                    '--step-data', '@OUTPUT@'],
                          build_always_stale: true,
                         )

step_data = custom_target(full_name + '.multisse.with_timing.stepdata.json',
                          input: [ara_py, app['ll'], app['oil']],
                          output: full_name + '.multisse.with_timing.stepdata.json',
                          depfile: full_name + '.dep',
                          command: [py3_inst, ara_py, app['ll'],
                                    '--dependency_file', '@DEPFILE@',
                                    '--oilfile', app['oil'],
                                    '--step-settings', with_timing_settings,
                                    '--timings', app['sys_timings'],
                                    '--step-data', '@OUTPUT@'],
                          build_always_stale: true,
                         )

subdir('gen')

subdir('bestof')
