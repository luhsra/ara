clang = find_program('clang', version: llvm_version)
nop = find_program('true')

# compiler flags to generate annotated IR
clang_flags = ['-S', '-g', '-emit-llvm', '-target', 'i386-pc-linux-gnu', '-fno-discard-value-names', '-fno-exceptions']
clang_flags += '-Wno-everything'
c_std = '-std=c11'
cxx_std = '-std=c++11'


# FreeRTOS examples

freertos_includes = ['-I', join_paths(meson.current_source_dir(), 'FreeRTOS', 'source', 'include')]

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
               'thesis_print',
               'topological_sort']
  ll_target = custom_target('freertos-' + app,
                            input : ['FreeRTOS/' + app + '.cc'],
                            output : ['freertos-' + app + '.ll'],
							depfile : 'freertos-' + app + '.ll.dep',
                            command : [clang, '@INPUT0@',
									   '-MD', '-MF', '@DEPFILE@',
                                       '-o', '@OUTPUT0@', cxx_std] +
									  libs_includes +
									  freertos_includes +
                                      clang_flags)
  set_variable('freertos_' + app.underscorify(), ll_target)
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
                            command : [clang, '@INPUT0@',
									   '-MD', '-MF', '@DEPFILE@',
                                       '-o', '@OUTPUT0@', cxx_std] +
									  osek_includes +
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
