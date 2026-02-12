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
  # 2x zephyr notify using hypercall z -> z, multiple sends after each other
  {'name': 'hc-zephyr2', 'do_timings': 'true', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-7.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-8.ll;'
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
  {'name': 'hc-bm-recv', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_bm_recv_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-bm-recv/Autosar-A/a.json;' +
      'BareMetal;subprojects/ara/appl/Xen/bare_metal/___hc_bm_recv_BareMetal_B_b.pi4.ll;callback;'
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
      'BareMetal;subprojects/ara/appl/Xen/bare_metal/___min_bm_BareMetal_A_main.pi4.ll;None;' 
      + 'BareMetal;subprojects/ara/appl/Xen/bare_metal/___min_bm_BareMetal_B_other.pi4.ll;None;' 
  },
  {'name': 'hardware', 'do_timings': 'true', 'guests':
      'BareMetal;subprojects/ara/appl/Xen/bare_metal/___hardware_BareMetal_A_hardware.pi4.ll;callback;'  +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hw.ll;'
  },
  
  # --------------------------- Paper ----------------------------------
    {'name': 'braking0', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a1.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b1.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json'
    },
    {'name': 'braking1', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a1.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b2.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json'
    },
    {'name': 'braking2', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a2.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b2.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json'
    },
    {'name': 'braking3', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b2.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json'
    },
    {'name': 'braking4', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b3.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json'
    },
    {'name': 'braking5', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b4.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json;'
        + 'BareMetal;subprojects/ara/appl/Xen/bare_metal/___braking_BareMetal_C_braking.pi4.ll;hmi_update;'       
    },
    {'name': 'braking55', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b4.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_BareMetal_C_c.pi4.ll;../subprojects/ara/appl/Xen/braking/BareMetal-C/c.json;'
    },
    {'name': 'braking6', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-1.ll;'
        + 'BareMetal;subprojects/ara/appl/Xen/bare_metal/___braking_BareMetal_C_braking.pi4.ll;hmi_update;'       
    },
    {'name': 'braking61', 'do_timings': 'true', 'guests':
        'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-2.ll;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a4.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'BareMetal;subprojects/ara/appl/Xen/bare_metal/___braking_BareMetal_C_braking.pi4.ll;hmi_update;'       
    },
    {'name': 'braking65', 'do_timings': 'true', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-3.ll;'      
    },
    {'name': 'hc-autosar-polled', 'do_timings': 'true', 'guests': 
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled/Autosar-A/a.json;' +
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled/Autosar-B/b.json'
    },
    {'name': 'hc-autosar-polled-2', 'do_timings': 'true', 'guests': 
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_2_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled-2/Autosar-A/a.json;' +
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled-2/Autosar-B/b.json'
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

# need this variable, even if subproject is loaded later
# its a bit ilegal!
zephyr = subproject('ara-zephyr-apps')
xen_zephry_kernel_targets = zephyr.get_variable('xen_zephry_kernel_targets')

# To rebuild while debuging
rebuild_lls = custom_target('xen-ara-autosar', 
            command: find_program('true'),
            output: 'xen-ara-autosar',
            depends: [autosar_ll_targets, bareMetal_ll_targets, xen_zephry_kernel_targets])

# must call: meson compile sse-native_sim-xen_static_msgq -v
# Create ninja target, run with: ninja subprojects/ara/appl/Xen/hypercall
foreach case: xen_testcases
  conf_data = configuration_data()
  conf_data.set('name', case['name'])
  conf_data.set('do_timings', case['do_timings'])
  conf_data.set('guests', case['guests'])
  conf_data.set('do_stats', 'false') # 'true' or 'false'

  name = case['name']
  settings = configure_file(input : files(f'hypersse.json.in'), output : f'hypersse-@name@.json',
              configuration : conf_data)

  # optinally add va_corrections here, file should be in the folder of this meson folder
  # also add ", '--va-corrections', corrections" to custom_target(command: ...)
  # corrections = files('va_corrections.json')
  custom_target('xen-ara-' + case['name'], 
            command: [py3_inst, ara_py, 'ignored', '--os', 'XEN', '--log-level', 'warn',
                '--step-settings', settings],
            output: name,
            depends : rebuild_lls,

  )
endforeach