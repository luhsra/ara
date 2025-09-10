# Xen testcases build file
# To add a testcase create a folder in ara/appl/Xen, then create a subfolder for each guest system.
# The folder name must match the 'name', guests are listed by their OS and afterwards OS specific config
#   Autosar: needs .ll and .json, for .ll add to ../AUTOSAR/meson.build

# Testcases
xen_testcases = [
  # Hypercalls
  # Classic MultiSSE with 2 cores
#   {'name': 'multicore', 'do_timings': 'true', 'guests':
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_multicore_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/multicore/Autosar-A/a.json;'
#   },
  # Minimal Example for hypercalls
  {'name': 'hypercall', 'do_timings': 'true', 'guests':
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-B/b.json'
  },
  # Minimal Example for hypercalls without timing information
  {'name': 'hypercall-not', 'do_timings': 'false', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hypercall/Autosar-B/b.json'
  },
  # Hypercalls with more syscalls
  {'name': 'hypercall-ext', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_ext_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercall-ext/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_ext_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hypercall-ext/Autosar-B/b.json'
  },
  {'name': 'hypercall-periodic', 'do_timings': 'true', 'guests':
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_periodic_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercall-periodic/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercall_periodic_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hypercall-periodic/Autosar-B/b.json'
  },
  # Complex without Hypercalls: 2 systems, one with alarm
  {'name': 'complex', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_complex_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/complex/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_complex_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/complex/Autosar-B/b.json'
  },
  # Big example with Hypercalls: 3 Systeme, A sendet zu festen Zeitpunkten Signale an B, C sendet ebenfalls an B, 3 verschiedene Events auf B.
  {'name': 'hypercomplex', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercomplex_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hypercomplex/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercomplex_Autosar_B_worker.pi4.ll;../subprojects/ara/appl/Xen/hypercomplex/Autosar-B/worker.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hypercomplex_Autosar_C_loop.pi4.ll;../subprojects/ara/appl/Xen/hypercomplex/Autosar-C/loop.json'
  },

  # With Zephyr
  # Zephyr
  {'name': 'zephyr', 'do_timings': 'false', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-A.ll;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_zephyr_Autosar_B_a.pi4.ll;../subprojects/ara/appl/Xen/zephyr/Autosar-B/a.json'
  },
  # "Zephyr", "subprojects/ara-zephyr-apps/appl/native_sim-xen_static_msgq.ll",
  # Zephyr with hypercalls
  {'name': 'zephyr-hc', 'do_timings': 'false', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-A2.ll;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_zephyr_hc_Autosar_B_a.pi4.ll;../subprojects/ara/appl/Xen/zephyr-hc/Autosar-B/a.json'
  },
  # Testing sleep with zephyr
  {'name': 'zephyr-sleep', 'do_timings': 'false', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-A3.ll;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_zephyr_sleep_Autosar_B_a.pi4.ll;../subprojects/ara/appl/Xen/zephyr-sleep/Autosar-B/a.json'
  },

  # No Hypercalls
  # Load 2x Autosar in HyperSSE: Kleinstmöglichestes System, verschmelzen der beiden SingleCore Systeme zu einem Hypervisor System.
  {'name': 'minimal', 'do_timings': 'false', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_minimal_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/minimal/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_minimal_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/minimal/Autosar-B/b.json'
  },
  # Load alarms into HyperSSE: indirekt wird aus dem SingleCore System ein MultiCore System.
  # MultiSSE und HyperSSE sollten hierbei das gleiche Ergebnis liefern
  {'name': 'alarm', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_alarm_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/alarm/Autosar-A/a.json;'
      
  },
  # Port of Automotive Benchmark
  {'name': 'automotiveB', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotiveB_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotiveB/Autosar-A/tasks.json;'
  },
  # Port of Automotive Benchmark
  {'name': 'automotiveBdouble', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotiveBdouble_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotiveBdouble/Autosar-A/tasks.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotiveBdouble_Autosar_B_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotiveBdouble/Autosar-B/tasks.json;'      
  },
  # Port of Automotive Benchmark
  {'name': 'automotiveBshared', 'do_timings': 'true', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotiveBshared_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotiveBshared/Autosar-A/tasks.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotiveBshared_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotiveBshared/Autosar-A/tasks.json;'      
  },
]

# Compile Autosar ll files
autosar_ll_targets = []
foreach app: autosar_targets
  if app['core'].contains('Xen')
    autosar_ll_targets += app['ll_pi4']
  endif
endforeach

# To rebuild while debuging
autosar_lls = custom_target('xen-ara-autosar', 
            command: find_program('true'),
            output: 'xen-ara-autosar',
            depends: autosar_ll_targets)

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
            depends : autosar_lls,

  )
endforeach