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
        "do_timings": true,
        "testname": "Alarm",
        "guests": ["Autosar", "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_alarm_a.pi4.ll",
                    "../subprojects/ara/appl/AUTOSAR/singlecore/xen/alarm/a.json"]
    }


# Complex Test
2 Systems, one with alarm. Need to synchronsize both for shutdown, therefore complex SP.

ninja ara@@run_autosar_singlecore_xen_complex_a_noopt_pi4 && ninja ara@@run_autosar_singlecore_xen_complex_b_noopt_pi4
ninja ara@@run_autosar_singlecore_xen_complex_multi_core_noopt_pi4

ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_complex_a_noopt_mod.pi4.ll && ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_complex_b_noopt_mod.pi4.ll
"HyperSSE": {
    "system_count": 2,
    "dom_files" : ["subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_complex_a.pi4.ll",
                "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_complex_b.pi4.ll"],
    "dom_oils" : ["../subprojects/ara/appl/AUTOSAR/singlecore/xen/complex/a.json", 
                    "../subprojects/ara/appl/AUTOSAR/singlecore/xen/complex/b.json"]
}


# Hypercalls
2 Systems, one sends an hypercall to the other one and starts a task.

ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_a_noopt_mod.pi4.ll && ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_b_noopt_mod.pi4.ll

/usr/lib/llvm-14/bin/clang -o subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_a.pi4.ll ../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercall/a.cc -MD -MF subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_a.pi4.ll.dep -std=c++11 -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/arm -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/arm/platforms/raspberry -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/.. -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/os -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/os/util -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/generic -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/generic -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/os -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/test -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/appl/AUTOSAR/source/os -ffunction-sections -fdata-sections -g -O0 -Xclang -disable-O0-optnone -fno-rtti -Wno-everything -fno-discard-value-names -fno-exceptions --target=arm-none-eabi -mthumb -mcpu=cortex-a72 -mthumb -mfloat-abi=soft -std=c++11 -O3 -ffixed-r9 -mcpu=cortex-a7 -DQEMU -O0 -S -emit-llvm && /usr/lib/llvm-14/bin/clang -o subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_b.pi4.ll ../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercall/b.cc -MD -MF subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_b.pi4.ll.dep -std=c++11 -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/arm -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/arm/platforms/raspberry -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/.. -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/os -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/os/util -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/generic -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/arch/generic -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/os -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/libs/autosar/test -I /home/sayna/Desktop/sra/master/parrot/subprojects/ara/appl/AUTOSAR/source/os -ffunction-sections -fdata-sections -g -O0 -Xclang -disable-O0-optnone -fno-rtti -Wno-everything -fno-discard-value-names -fno-exceptions --target=arm-none-eabi -mthumb -mcpu=cortex-a72 -mthumb -mfloat-abi=soft -std=c++11 -O3 -ffixed-r9 -mcpu=cortex-a7 -DQEMU -O0 -S -emit-llvm


"HyperSSE": {
	"do_timings": true,
	"testname": "Hypercall",
	"guests": ["Autosar", "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_a.pi4.ll",
				"../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercall/a.json", 
				"Autosar", 
                "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercall_b.pi4.ll", 
                "../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercall/b.json"
			]
}



# Hypercalls Complex
3 Systeme, A sendet zu festen Zeitpunkten Signale an B, C sendet ebenfalls an B, 3 verschiedene Events auf B.
ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercomplex_loop_noopt_mod.pi4.ll && ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercomplex_worker_noopt_mod.pi4.ll && ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercomplex_a_noopt_mod.pi4.ll


"HyperSSE": {
    "system_count": 3,
    "dom_files" : ["subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercomplex_a.pi4.ll",
                "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercomplex_worker.pi4.ll",
                "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_hypercomplex_loop.pi4.ll"],
    "dom_oils" : ["../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercomplex/a.json", 
                    "../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercomplex/worker.json",
                    "../subprojects/ara/appl/AUTOSAR/singlecore/xen/hypercomplex/loop.json"]
}


# Spinlock
ninja ara@@run_autosar_singlecore_xen_spinlock_spinlock_noopt_pi4
-> braucht Hypercalls!

# IIT



# Zephyr ?
/usr/bin/python3 subprojects/ara/ara.py subprojects/ara-zephyr-apps/appl/qemu_cortex_m3-static_msgq.ll --os Zephyr --ir_output subprojects/ara-zephyr-apps/appl/qemu_cortex_m3-static_msgq_mod.ll --step-settings ../subprojects/ara/settings/zephyr.json autosar_singlecore_xen_hypercall_b_noopt_autosar.pi4.cc --timing BB


/usr/bin/python3 subprojects/ara/ara.py subprojects/ara-zephyr-apps/appl/native_sim-static_msgq.ll --os Zephyr --log-level info --with-stubs --va-corrections /home/sayna/Desktop/sra/master/parrot/settings/no_corrections.json --step-settings sse_native_sim-static_msgq.json


	"HyperSSE": {
		"do_timings": false,
		"testname": "Cross-OS",
		"guests": ["Zephyr", "subprojects/ara-zephyr-apps/appl/native_sim-static_msgq.ll",
		"Autosar", "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_zephyr_autosar.pi4.ll",
		"../subprojects/ara/appl/AUTOSAR/singlecore/xen/zephyr/autosar.json"]
	}

# Zephyr Hypercall    	
	"HyperSSE": {
		"do_timings": false,
		"testname": "Cross-OS-HC",
		"guests": ["Zephyr", "subprojects/ara-zephyr-apps/appl/native_sim-xen_static_msgq.ll",
		"Autosar", "subprojects/ara/appl/AUTOSAR/autosar_singlecore_xen_zephyr_hc_autosar.pi4.ll",
		"../subprojects/ara/appl/AUTOSAR/singlecore/xen/zephyr-hc/autosar.json"]
	}