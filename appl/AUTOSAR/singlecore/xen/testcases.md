
# Zephyr
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

