name_prefix_trampoline = 'autosar_multicore_trampoline_'
tramp_clang = generator(clang,
                        output : '@BASENAME@.ll',
                        depfile : '@BASENAME@.ll.dep',
                        arguments : [clang_base, cxx_std, ir_flags, clang_flags, libs_includes, '-I', meson.current_source_dir()])

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
