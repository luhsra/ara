name = 'mc_alarms_s1'
lls = tramp_clang.process(name + '.cc', 'task1_instance.cc', 'task2_instance.cc')
ll = custom_target(name,
                   input : lls,
                   output : name + '.ll',
                   depfile : name + '.ll.dep',
                   command : llvm_link_cmd)

autosar_targets += {'full_name': name,
                    'oil': 'mc_alarms_s1.oil',
                    'll': ll,
                    'core': 'multicore',
                    'mtrace': 'trace.json',
                    'sys_test': 'trace.json',
                   }

