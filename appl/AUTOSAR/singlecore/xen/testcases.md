# First create ll files for systems with first ninja cmd. Run MultiSSE with second cmd. Edit hypersse.json and run with F5 for HyperSSE

# Minimal
Kleinstmöglichestes System, verschmelzen der beiden SingleCore Systeme zu einem Hypervisor System.

ninja ara@@run_autosar_singlecore_xen_minimal_a_noopt_pi4 && ninja ara@@run_autosar_singlecore_xen_minimal_b_noopt_pi4
ninja ara@@run_autosar_singlecore_xen_minimal_multi_core_noopt_pi4

"HyperSSE": {
    "system_count": 2,
    "dom_files" : ["subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_minimal_a.pi4.ll",
                "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_minimal_b.pi4.ll"],
    "dom_oils" : ["../subprojects/ara/appl/AUTOSAR/singlecore/xen/minimal/a.json", 
                    "../subprojects/ara/appl/AUTOSAR/singlecore/xen/minimal/b.json"]
}

# Alarm Test
Hinzufügen eines Alarms, indirekt wird aus dem SingleCore System ein MultiCore System.
MultiSSE und HyperSSE sollten hierbei das gleiche Ergebnis liefern.

ninja ara@@run_autosar_singlecore_xen_alarm_a_noopt_pi4

"HyperSSE": {
    "system_count": 1,
    "dom_files" : ["subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_alarm_test.pi4.ll"],
    "dom_oils" : ["../subprojects/ara/appl/AUTOSAR/singlecore/xen/alarm_test.json"]
}

# Complex Test
2 Systems, one with alarm. Need to synchronsize both for shutdown, therefore complex SP.

ninja ara@@run_autosar_singlecore_xen_complex_a_noopt_pi4 && ninja ara@@run_autosar_singlecore_xen_complex_b_noopt_pi4
ninja ara@@run_autosar_singlecore_xen_complex_multi_core_noopt_pi4

"HyperSSE": {
    "system_count": 2,
    "dom_files" : ["subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_complex_a.pi4.ll",
                "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_complex_b.pi4.ll"],
    "dom_oils" : ["../subprojects/ara/appl/AUTOSAR/singlecore/xen/complex/a.json", 
                    "../subprojects/ara/appl/AUTOSAR/singlecore/xen/complex/b.json"]
}


# IIT
# Hypercalls


# Spinlock
ninja ara@@run_autosar_singlecore_xen_spinlock_spinlock_noopt_pi4
-> braucht Hypercalls!