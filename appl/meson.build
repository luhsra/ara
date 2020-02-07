

# FreeRTOS examples

freertos_targets = []
foreach app : ['a',
               'abb_merge',
               'argument_load',
               'c',
               'critical_region_detection',
               'dead_code',
               'deadlock',
               'dominator',
               'eventgroup',
               'f',
               'g',
               'icfg',
               'invalid_isr_syscall',
               'invalid_mutex',
               'invalid_semaphore',
               'loop_detection',
               'multi_exit',
               'ospert',
               'priority_inversion',
               'sse',
               'start_scheduler_relation',
               'syscall',
			   'simple_print',
               'thesis_print',
               'topological_sort']
  ll_target = custom_target('freertos-' + app,
                            input : ['FreeRTOS/' + app + '.cc'],
                            output : ['freertos-' + app + '.ll'],
							depfile : 'freertos-' + app + '.ll.dep',
                            command : clang_cpp +
									  libs_includes +
									  ir_flags +
                                      clang_flags)
  set_variable('freertos_' + app.underscorify(), ll_target)

  o_target = custom_target('freertos-' + app + '.o',
                            input : ll_target,
                            output : ['freertos-' + app + '.ll.o'],
                            command : llc_cmd)

  foreach t : ara_gen_freertos_targets
	name_prefix = 'freertos-' + app + '-' + t
	os_target = custom_target(name_prefix + '-os',
							  input: ll_target,
							  output: [name_prefix + '-os.cc',
									   name_prefix + '-os.cc.startup.s'],
							  command: get_variable('ara_gen_' + t)
							 )

	elf_target = custom_target(name_prefix + '.elf',
							   input: [o_target,
									   os_target,
									   libs_targets,
									   get_variable('libfreertos_'+t)],
							   output: name_prefix + '.elf',
							   depfile: name_prefix + '.elf.dep',
							   command: clang_cpp +
										libs_includes +
										ld_flags +
										clang_flags)
	bin_target = custom_target(name_prefix + '.bin',
							   input: [elf_target],
							   output: name_prefix + '.bin',
							   command: objcopy_cmd)
	run_target('flash_' + name_prefix, command: ['st-flash', 'write', bin_target, '0x8000000'])
	run_target('size_' + name_prefix, command: ['arm-none-eabi-size', elf_target])

  endforeach

  freertos_targets += ll_target
endforeach

# gpslogger is special
subdir('FreeRTOS/GPSLogger')
freertos_targets += gpslogger_targets

subdir('FreeRTOS/SmartPlug')
freertos_targets += smartplug_targets

freertos_examples = run_target('freertos-examples',
                               command: nop,
                               depends: freertos_targets)

# OSEK examples

osek_includes = ['-I', join_paths(meson.current_source_dir(), 'OSEK', 'source', 'os')]
osek_folder = 'OSEK'

osek_targets = []
foreach app : [['a',                     'a.oil'],
               ['b',                     'oilfile.oil'],
               ['c',                     'oilfile.oil'],
               ['coptermok',             'coptermok.oil'],
               ['copter-without-alarms', 'copter-without-alarms.oil'],
               ['oiltest',               'oiltest.oil']]
  ll_target = custom_target('osek-' + app[0],
                            input : [join_paths([osek_folder, app[0] + '.cc'])],
                            output : ['osek-' + app[0] + '.ll'],
							depfile : 'osek-' + app[0] + '.ll.dep',
                            command : clang_cpp +
									  osek_includes +
									  ir_flags +
									  clang_flags)
    set_variable('osek_' + app[0].underscorify(), [ll_target, files(join_paths([osek_folder, app[1]]))])
    osek_targets += ll_target
endforeach

osek_examples = run_target('osek-examples',
                           command: nop,
                           depends: osek_targets)

examples = run_target('examples',
                      command: nop,
                      depends: [osek_targets, freertos_targets])
