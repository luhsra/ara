# Xen testcases build file
# To add a testcase create a folder in ara/appl/Xen, then create a subfolder for each guest system.
# The folder name must match the 'name', guests are listed by their OS and afterwards OS specific config:
#   Autosar: needs .ll and .json, to create them add a target in ../AUTOSAR/meson.build
#   Zephyr: needs .ll, to create it add a target in subprojects/ara-zephyr-apps/appl/meson.build
#       it also needs a different naming scheme, because the folder names have to be unique
#   BareMetal/Android: needs .ll and names of callbacks functions, create a target in ../BareMetal/meson.build

xen_testcases = [

  # --------------------------- minimal ----------------------------------
  # load two singlecore autosar guests into HyperSSE
  {'name': 'min-autosar', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_autosar_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/min-autosar/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_autosar_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/min-autosar/Autosar-B/b.json'
  },
  # load two singlecore zephyr guests into HyperSSE
  {'name': 'min-zephyr', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-1.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-2.ll;'
  },
  # load two singlecore bareMetal/Android guests into HyperSSE
  {'name': 'min-baremetal', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_min_baremetal_BareMetal_A_a.pi4.ll;None;' +
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_min_baremetal_BareMetal_B_b.pi4.ll;None;' 
  },
  # load one autosar and one zephyr guest into HyperSSE, both use syscalls
  {'name': 'min-az', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_az_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/min-az/Autosar-A/a.json;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-3.ll;'
  },
  # load one zephyr and one baremetal guest into HyperSSE, both use syscalls
  {'name': 'min-zb', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-min-4.ll;' +
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_min_zb_BareMetal_B_b.pi4.ll;None;' 
  },
  # load one baremetal and one zephyr guest into HyperSSE, both use syscalls
  {'name': 'min-ba', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_min_ba_BareMetal_A_a.pi4.ll;None;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_min_ba_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/min-ba/Autosar-B/b.json'
  },
  # load many singlecore autosar guests into HyperSSE
  {'name': 'many', 'do_timings': 'false', 'testsuite': '10s', 'guests':
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-B/b.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_C_c.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-C/c.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_D_d.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-D/d.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_E_e.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-E/e.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_many_Autosar_F_f.pi4.ll;../subprojects/ara/appl/Xen/many/Autosar-F/f.json'
  },

  # --------------------------- hypercalls  ----------------------------------
  # 2x autosar notify using hypercall a -> a
  {'name': 'hc-autosar', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar/Autosar-B/b.json'
  },
  # 2x zephyr notify using hypercall z -> z
  {'name': 'hc-zephyr', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-1.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-2.ll;'
  },
  # 2x bareMetal notify using hypercall b -> b
  {'name': 'hc-baremetal', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_baremetal_BareMetal_A_a.pi4.ll;None;' +
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_baremetal_BareMetal_B_b.pi4.ll;event;'
  },
  # 2x autosar notify using hypercall a <- a
  {'name': 'hc-autosar2', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar2_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar2/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar2/Autosar-B/b.json'
  },
  # 2x zephyr notify using hypercall z <- z
  {'name': 'hc-zephyr2', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-7.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-8.ll;'
  },
  # 2x bareMetal notify using hypercall b <- b
  {'name': 'hc-baremetal2', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_baremetal2_BareMetal_A_a.pi4.ll;event;' +
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_baremetal2_BareMetal_B_b.pi4.ll;None;'
  },
  # A -> Z
  {'name': 'hc-a-z1', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_a_z1_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-a-z1/Autosar-A/a.json;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-3.ll;'
  },
  # Z -> B
  {'name': 'hc-z-b1', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-4.ll;' +
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_z_b1_BareMetal_B_b.pi4.ll;event;'
  },
  # B -> A
  {'name': 'hc-b-a1', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_b_a1_BareMetal_A_a.pi4.ll;None;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_b_a1_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-b-a1/Autosar-B/b.json'
  },
  # A <- Z
  {'name': 'hc-a-z2', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_a_z2_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-a-z2/Autosar-A/a.json;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-5.ll;'
  },
  # Z <- B
  {'name': 'hc-z-b2', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-6.ll;' +
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_z_b2_BareMetal_B_b.pi4.ll;None;'
  },
  # B <- A
  {'name': 'hc-b-a2', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_b_a2_BareMetal_A_a.pi4.ll;event;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_b_a2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-b-a2/Autosar-B/b.json'
  },
  # 2x autosar notify using hypercall a -> a notiming
  {'name': 'hc-autosar-notiming', 'do_timings': 'false', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_notiming_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-notiming/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_notiming_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-notiming/Autosar-B/b.json'
  },
  # 2x zephyr notify using hypercall z -> z without iit
  {'name': 'hc-zephyr-notiming', 'do_timings': 'false', 'testsuite': '10s', 'guests': 
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-9.ll;' +
      'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hc-10.ll;'
  },
  # 2x bareMetal notify using hypercall b -> b without iit
  {'name': 'hc-baremetal-notiming', 'do_timings': 'false', 'testsuite': '10s', 'guests': 
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_baremetal_notiming_BareMetal_A_a.pi4.ll;None;' +
      'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hc_baremetal_notiming_BareMetal_B_b.pi4.ll;event;'
  },
  # A -> A, but masked + polled. No 
  {'name': 'hc-autosar-polled', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled/Autosar-B/b.json'
  },
  {'name': 'hc-autosar-polled-2', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_2_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled-2/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_hc_autosar_polled_2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/hc-autosar-polled-2/Autosar-B/b.json'
  },
#   # Autosar alarm, virtual IRQ gets modeled as addiontal domain
  {'name': 'alarm', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_alarm_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/alarm/Autosar-A/a.json;'
  },
#   # Autosar alarm on 2nd domain, with additonal hypercalls
#   {'name': 'alarm-2', 'do_timings': 'true', 'guests': 
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_alarm_2_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/alarm-2/Autosar-A/a.json;' +
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_alarm_2_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/alarm-2/Autosar-B/b.json'
#   },

#   # Single Zephyr guest, bug in SSE does not continue after one sleep
#   # TODO: thread does not wake up from first sleep
#   # (not relevant for HyperSSE)
#   {'name': 'zephyr-sleep', 'do_timings': 'true', 'guests': 
#       'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-sleep.ll;'
#   },


  # --------------------------- shared memory  ----------------------------------
  # 2x autosar ro
  {'name': 'shamem-autosar-ro', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_ro_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-ro/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_ro_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-ro/Autosar-B/b.json'
  },
  # 2x autosar RAW
  {'name': 'shamem-autosar-raw', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_raw_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-raw/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_raw_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-raw/Autosar-B/b.json'
  },
  # 2x autosar WAR
  {'name': 'shamem-autosar-war', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_war_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-war/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_war_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-war/Autosar-B/b.json'
  },
  # 2x autosar Unknown (if read or write first)
  {'name': 'shamem-autosar-unknown', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_unknown_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-unknown/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_unknown_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar-unknown/Autosar-B/b.json'
  },
  # BUGGED! 4x autosar with ReadAfterWrite, WriteAfterRead, Unkown
  {'name': 'shamem-autosar', 'do_timings': 'true', 'testsuite': 'none', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar/Autosar-B/b.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_Autosar_C_c.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar/Autosar-C/c.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_shamem_autosar_Autosar_D_d.pi4.ll;../subprojects/ara/appl/Xen/shamem-autosar/Autosar-D/d.json'
  },

  # --------------------------- COMPLEX ----------------------------------
  # 2x autosar, shows Hypercalls back and forth
  {'name': 'pingpong', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_pingpong_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/pingpong/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_pingpong_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/pingpong/Autosar-B/b.json'
  },
  # Send Receive Autosar example
  {'name': 'sendrecv-a', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_a_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-a/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_a_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-a/Autosar-B/b.json'
  },
  # Send Receive Autosar example
  {'name': 'sendrecv-b', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_b_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-b/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_sendrecv_b_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/sendrecv-b/Autosar-B/b.json'
  },
#   # 3 systems, A sends via 2 different channels to B, while C also sends to B
  {'name': 'channels', 'do_timings': 'true', 'testsuite': '10s', 'guests': 
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_channels_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/channels/Autosar-A/a.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_channels_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/channels/Autosar-B/b.json;' +
      'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_channels_Autosar_C_c.pi4.ll;../subprojects/ara/appl/Xen/channels/Autosar-C/c.json'
  },
#   # port of autosar/multicore/andreas/ipi/b
#   {'name': 'ipi', 'do_timings': 'true', 'guests': 
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_A_a.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-A/a.json;' +
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_B_b.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-B/b.json;' +
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_C_c.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-C/c.json;' +
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_ipi_Autosar_D_d.pi4.ll;../subprojects/ara/appl/Xen/ipi/Autosar-D/d.json'
#   },
#   # Port of Automotive Benchmark, 2 instances
#   {'name': 'automotive-1', 'do_timings': 'true', 'guests': 
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_1_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-1/Autosar-A/tasks.json;' +
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_1_Autosar_B_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-1/Autosar-B/tasks.json;'      
#   },
#   # Port of Automotive Benchmark, the same instance twice (addional stress test)
#   {'name': 'automotive-2', 'do_timings': 'true', 'guests': 
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_2_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-2/Autosar-A/tasks.json;' +
#       'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_automotive_2_Autosar_A_tasks.pi4.ll;../subprojects/ara/appl/Xen/automotive-2/Autosar-A/tasks.json;'      
#   },

#   # --------------------------- BareMetal ----------------------------------
#   {'name': 'hardware', 'do_timings': 'true', 'guests':
#       'BareMetal;subprojects/ara/appl/BareMetal/___Xen_hardware_BareMetal_A_hardware.pi4.ll;callback;'  +
#       'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-hw.ll;'
#   },
  
  # --------------------------- Paper ----------------------------------
  # This list of tests belong to our paper for the ECRTS-26, see our ecrts-hypersse repository.
  #  Most imporant are brakingUnrolled and brakingUnrolledSlowZ, which show how the example meets or fails its timing requirements.
  #  For Visualizing the graphs, breakingCheck is best suited; breakingNoCheck shows the available branches depending on the timing, but does not select which one occurs when.
    # loop no prediction case, graph is fully correct, but does not check if calc was in time
    {'name': 'brakingNoCheck', 'do_timings': 'true', 'testsuite': '10s', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a1_loop_no_predict.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-1-AckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
    },
    # loop with prediction case, it checks if calc is in time, but only for the first two LOOP iterations
    {'name': 'brakingCheck', 'do_timings': 'true', 'testsuite': '10s', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a2_loop.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-1-AckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
    },
    # unrolled loop with prediction case, graph is hard to read, but every iteration is checked
    {'name': 'brakingUnrolled', 'do_timings': 'true', 'testsuite': '10s', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3_unrolled.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-1-AckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
    },
    # loop no prediction case, graph is fully correct, but does not check if calc was in time
    {'name': 'brakingNoCheckSlowZ', 'do_timings': 'true', 'testsuite': '10s', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a1_loop_no_predict.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-2-SlowAckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
    },
    # loop with prediction case, it checks if calc is in time, but only for the first two LOOP iterations
    {'name': 'brakingCheckSlowZ', 'do_timings': 'true', 'testsuite': '10s', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a2_loop.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-2-SlowAckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
    },
    # unrolled loop with prediction case, graph is hard to read, but every iteration is checked
    {'name': 'brakingUnrolledSlowZ', 'do_timings': 'true', 'testsuite': '10s', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3_unrolled.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-2-SlowAckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
    },
    # ONLY AUTOSAR, like brakingUnrolled: unrolled loop with prediction case, graph is hard to read, but every iteration is checked
    {'name': 'brakingAutosarUnrolled', 'do_timings': 'true', 'testsuite': '10s', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3_unrolled.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_B_b1_ack_hmi.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-B/b.json;'
        + 'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_BareMetal_C_c_autosar.pi4.ll;../subprojects/ara/appl/Xen/braking/BareMetal-C/c.json;'
    },
    # NO TIMES:brakingUnrolled: unrolled loop with prediction case, graph is hard to read, but every iteration is checked
    #  should take ~42s: Number of vertices: 983, Number of edges: 6261, Number of SPs: 719, Number of LAbSSs: 201
    #  but does not have a verifed soluation, because the graph is not readable.
    {'name': 'brakingNoTimesUnrolled', 'do_timings': 'false', 'testsuite': 'none', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a3_unrolled.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-1-AckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
    },

  # --------------------------- EXTRA (not included in TestSuite ara-xen-eval ----------------------------------
    # this test takes very long and might never finish. This is probaly because the analysis creates a large cross-produkt of states, and because there is a loop it the app 
    #  it tries every state could also point to itself in a later loop iteration.
    {'name': 'brakingEXTRANoTimesCheck', 'do_timings': 'false', 'testsuite': 'none', 'guests':
        'Autosar;subprojects/ara/appl/AUTOSAR/autosar____Xen_braking_Autosar_A_a2_loop.pi4.ll;../subprojects/ara/appl/Xen/braking/Autosar-A/a.json;'
        + 'Zephyr;subprojects/ara-zephyr-apps/appl/native_sim-Zephyr-B-1-AckHMI.ll;'
        + 'BareMetal;subprojects/ara/appl/BareMetal/___Xen_braking_BareMetal_C_c_baremetal.pi4.ll;hmi_update;' 
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

  name = case['name']
  do_timings = case['do_timings']
  guests = case['guests']
  
  do_stats = 'false'
  dynamic_step_settings=f'{"HyperSSE": {"do_stats": @do_stats@, "testname": "@name@", "do_timings": @do_timings@, "guests": "@guests@"}}'
  do_stats = 'true'
  testsuite_dynamic_step_settings=f'{"HyperSSE": {"do_stats": @do_stats@, "testname": "@name@", "do_timings": @do_timings@, "guests": "@guests@"}}'

  # optinally add va_corrections here, file should be in the folder of this meson folder
  # also add ", '--va-corrections', corrections" to custom_target(command: ...)
  # corrections = files('va_corrections.json')
  custom_target('xen-ara-' + case['name'], 
            command: [py3_inst, ara_py, 'ignored', '--os', 'XEN', '--log-level', 'warn',
                '--step-settings', files('../../settings/hypersse_xen.json'), '--dynamic-step-settings', dynamic_step_settings],
            output: name,
            depends : rebuild_lls,
  )

  custom_target('testsuite-xen-ara-' + case['name'], 
            command: [py3_inst, ara_py, 'ignored', '--os', 'XEN', '--log-level', 'warn',
                '--step-settings', files('../../settings/hypersse_xen_testsuite.json'), '--dynamic-step-settings', testsuite_dynamic_step_settings],
            output: 'testsuite-'+name,
            depends : rebuild_lls,
  )
endforeach
