clang = find_program('clang-7')
nop = find_program('true')

# compiler flags to generate annotated IR
clang_flags = ['-S', '-g', '-emit-llvm', '--std=c++11', '-target', 'i386-pc-linux-gnu', '-fno-discard-value-names']


# FreeRTOS examples

freertos_path = 'FreeRTOS/source/include'

freertos_includes = files(join_paths(freertos_path, 'croutine.h'),
                          join_paths(freertos_path, 'event_groups.h'),
                          join_paths(freertos_path, 'FreeRTOS.h'),
                          join_paths(freertos_path, 'FreeRTOSConfig.h'),
                          join_paths(freertos_path, 'list.h'),
                          join_paths(freertos_path, 'queue.h'),
                          join_paths(freertos_path, 'task.h'))

freertos_targets = []
foreach app : ['a', 'invalid_isr_syscall', 'c', 'loop_detection', 'topological_sort', 'f', 'g',
               'argument_load', 'start_scheduler_relation', 'deadlock', 'dominator',
               'eventgroup', 'invalid_mutex', 'priority_inversion', 'critical_region_detection', 'invalid_semaphore','thesis_print' ]
  freertos_targets += custom_target('freertos-' + app,
                                    input : ['FreeRTOS/' + app + '.cc'] + freertos_includes,
                                    output : ['freertos-' + app + '.ll'],
                                    command : [clang, '@INPUT0@',
                                               '-o', '@OUTPUT0@'] +
                                              clang_flags)
endforeach

# gpslogger is special
subdir('FreeRTOS/GPSLogger')
freertos_targets += gpslogger_targets

freertos_examples = run_target('freertos-examples',
                               command: nop,
                               depends: freertos_targets)

# OSEK examples

osek_path = 'OSEK/source/os'

osek_includes = files(join_paths(osek_path, 'alarm.h'),
                      join_paths(osek_path, 'os.h'),
                      join_paths(osek_path, 'timing.h'),
                      join_paths(osek_path, 'counter.h'),
                      join_paths(osek_path, 'timing.h'),
                      join_paths(osek_path, 'osek_types.h'))

osek_targets = []
foreach app : ['a', 'b', 'c', 'coptermok']
  osek_targets += custom_target('osek-' + app,
                                input : ['OSEK/' + app + '.cc'] + osek_includes,
                                output : ['osek-' + app + '.ll'],
                                command : [clang, '@INPUT0@',
                                           '-o', '@OUTPUT0@'] +
                                           clang_flags)

endforeach

osek_examples = run_target('osek-examples',
                           command: nop,
                           depends: osek_targets)

examples = run_target('examples',
                      command: nop,
                      depends: [osek_targets, freertos_targets])
