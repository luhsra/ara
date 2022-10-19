name = fs.name(run_command('pwd', check:true).stdout().strip())
c_files = files(name + '.cc', 'task1_instance.cc', 'task2_instance.cc')

# TODO: search for bug if used with .process(file1, file2) resulting in all clang calls use -o file1.ll
lls = []
foreach c_file : c_files
  ll = tramp_clang.process(c_file)
  lls += ll
endforeach
ll = custom_target(name,
                   input : lls,
                   output : name + '.ll',
                   depfile : name + '.ll.dep',
                   command : llvm_link_cmd)

app = {'full_name': name_prefix_trampoline + name,
       'name': name,
       'oil': files('system.json'),
       'll': ll,
       'core': 'multicore',
      }

if fs.exists('trace.json')
  app += {'mtrace': files('trace.json')}
  app += {'sys_test': files('trace.json')}
endif

if fs.exists('timings.json')
  sys_timings = files('timings.json')
else
  sys_timings = disabler()
endif
app += {'sys_timings': sys_timings}

autosar_targets += [app]


