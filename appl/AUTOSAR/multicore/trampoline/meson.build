name_prefix_trampoline = 'autosar_multicore_trampoline_'
clang_base = toolchains.get_variable('clang_base')
cxx_std = toolchains.get_variable('cxx_std')
tramp_clang = generator(clang,
                        output : '@BASENAME@.ll',
                        depfile : '@BASENAME@.ll.dep',
                        arguments : [clang_base, cxx_std, ir_flags, autosar_posix_clang_flags, clang_flags, posix_autosar_includes, autosar_includes, '-I', meson.current_source_dir()])

subdir('mc_alarms_s1')
subdir('mc_appTermination_s1')
subdir('mc_autostart_s1')
subdir('mc_autostart_s2')
# subdir('mc_autostart_s3')
subdir('mc_coreid_s1')
subdir('mc_eventSetting_s1')
subdir('mc_events_s1')
subdir('mc_reschedule_s1')
# subdir('mc_schedtables_s1')
subdir('mc_scheduling_s1')
subdir('mc_spinlocks_s1')
subdir('mc_startOs_s1')
subdir('mc_startup_s1')
subdir('mc_taskActivation_s1')
subdir('mc_taskChaining_s1')
subdir('mc_taskTermination_s1')
subdir('mc_taskTermination_s2')
