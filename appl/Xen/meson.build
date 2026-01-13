# Xen testcases build file
# To add a testcase create a folder in ara/appl/Xen, then create a subfolder for each guest system.
# The folder name must match the 'name', guests are listed by their OS and afterwards OS specific config
#   Autosar: needs .ll and .json, for .ll add to ../AUTOSAR/meson.build

xen_testcases = [

  # --------------------------- minimal ----------------------------------
  # load two singlecore autosar guests into HyperSSE
  {'name': 'min-autosar', 'do_timings': 'false', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_autosar_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/min-autosar/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_autosar_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/min-autosar/Autosar-B/b.json'
  },
  # load two singlecore zephyr guests into HyperSSE
  {'name': 'min-zephyr', 'do_timings': 'false', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-1.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-2.ll;'
  },
  # load one autosar and one zephyr guest into HyperSSE
  {'name': 'min-1', 'do_timings': 'false', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_1_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/min-1/Autosar-A/a.json;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-3.ll;'
  },
  # load one zephyr and one autosar guest into HyperSSE
  {'name': 'min-2', 'do_timings': 'false', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-4.ll;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/min-2/Autosar-B/b.json'
  },
  # load many singlecore autosar guests into HyperSSE
  {'name': 'many', 'do_timings': 'false', 'guests':
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-B/b.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_C_c.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-C/c.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_D_d.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-D/d.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_E_e.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-E/e.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_F_f.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-F/f.json'
  },
  # Autosar alarm, virtual IRQ gets modeled as addiontal domain
  {'name': 'alarm', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_alarm_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/alarm/Autosar-A/a.json;'
  },
  # Autosar alarm on 2nd domain, with additonal hypercalls
  {'name': 'alarm-2', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_alarm_2_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/alarm-2/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_alarm_2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/alarm-2/Autosar-B/b.json'
  },
  # Single Zephyr guest, bug in SSE does not continue after one sleep
  # TODO: thread does not wake up from first sleep
  {'name': 'zephyr-sleep', 'do_timings': 'true', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-sleep.ll;'
  },


  # --------------------------- hypercalls  ----------------------------------
  # 2x autosar notify using hypercall a -> a
  {'name': 'hc-autosar', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar/Autosar-B/b.json'
  },
  # 2x zephyr notify using hypercall z -> z
  {'name': 'hc-zephyr', 'do_timings': 'true', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-1.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-2.ll;'
  },
  # notify using hypercall a <- z
  {'name': 'hc-1', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_1_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-1/Autosar-A/a.json;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-3.ll;'
  },
  # notify using hypercall z <- a 
  {'name': 'hc-2', 'do_timings': 'true', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-4.ll;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-2/Autosar-B/b.json'
  },
  # 2x autosar notify using hypercall a -> b without IIT
  {'name': 'hc-autosar-noiit', 'do_timings': 'false', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_noiit_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-noiit/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_noiit_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-noiit/Autosar-B/b.json'
  },
  # 2x zephyr notify using hypercall a -> b without IIT
  # TODO: HSTG does not look correct, SP are right, but wrong follow up states
  {'name': 'hc-zephyr-noiit', 'do_timings': 'false', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-5.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-6.ll;'
  },


  # --------------------------- COMPLEX ----------------------------------
  # 2x autosar, shows Hypercalls back and forth
  {'name': 'pingpong', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_pingpong_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/pingpong/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_pingpong_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/pingpong/Autosar-B/b.json'
  },
  # Send Receive Autosar example
  {'name': 'sendrecv-a', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_a_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-a/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_a_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-a/Autosar-B/b.json'
  },
  # Send Receive Autosar example
  {'name': 'sendrecv-b', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_b_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-b/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_b_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-b/Autosar-B/b.json'
  },
  # 3 systems, A sends via 2 different channels to B, while C also sends to B
  {'name': 'channels', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_channels_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/channels/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_channels_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/channels/Autosar-B/b.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_channels_Autosar_C_c.pi4.ll;../subprojects/ara/appl/Xen/channels/Autosar-C/c.json'
  },
  # port of autosar/multicore/andreas/ipi/b
  {'name': 'ipi', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-B/b.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_C_c.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-C/c.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_D_d.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-D/d.json'
  },
  # Port of Automotive Benchmark, 2 instances
  {'name': 'automotive-1', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_1_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-1/Autosar-A/tasks.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_1_Autosar_B_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-1/Autosar-B/tasks.json;'      
  },
  # Port of Automotive Benchmark, the same instance twice (addional stress test)
  {'name': 'automotive-2', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_2_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-2/Autosar-A/tasks.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_2_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-2/Autosar-A/tasks.json;'      
  },

  # --------------------------- BareMetal ----------------------------------
  {'name': 'min-bm', 'do_timings': 'true', 'guests': 
      'BareMetal;subprojects/ara/appl/Xen/bare_metal/___min_bm_BareMetal_A_main.pi4.ll;None'      
  },
  {'name': 'hardware', 'do_timings': 'true', 'guests':
      'BareMetal;subprojects/ara/appl/Xen/bare_metal/___hardware_BareMetal_A_hardware.pi4.ll;callback;'  +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hw.ll;'
  },
  
  # --------------------------- Paper ----------------------------------
    {'name': 'braking', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        # + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B.ll;'
        # 'BareMetal;subprojects/ara/appl/Xen/bare_metal/___min_bm_BareMetal_A_main.pi4.ll;None'      
    },
]

# Compile Autosar ll files
autosar_ll_targets = []
foreach app: autosar_targets
  if app['core'].contains('Xen')
    autosar_ll_targets += app['ll_pi4']
  endif
endforeach

# Compile BareMetal ll files
bareMetal_ll_targets = []
foreach app: baremetal_targets
    bareMetal_ll_targets += app['ll_pi4']
endforeach

# To rebuild while debuging
rebuild_lls = custom_target('xen-ara-autosar', 
            command: find_program('true'),
            output: 'xen-ara-autosar',
            depends: [autosar_ll_targets, bareMetal_ll_targets])

# must call: meson compile sse-native_sim-xen_static_msgq -v
# Create ninja target, run with: ninja subprojects/ara/appl/Xen/hypercall
foreach case: xen_testcases
  conf_data = configuration_data()
  conf_data.set('name', case['name'])
  conf_data.set('do_timings', case['do_timings'])
  conf_data.set('guests', case['guests'])
  conf_data.set('do_stats', 'true') # 'true' or 'false'

  name = case['name']
  settings = configure_file(input : files(f'hypersse.json.in'), output : f'hypersse-@name@.json',
              configuration : conf_data)

  custom_target('xen-ara-' + case['name'], 
            command: [py3_inst, ara_py, 'ignored', '--os', 'XEN', '--log-level', 'warn',
                '--step-settings', settings],
            output: name,
            depends : rebuild_lls,

  )
endforeach