#include "constructors.h"
#include "serial.h"
#include "timer.h"
#include "machine.h"
#include "dispatch.h"
#include "os/spinlock.h"
#include "boot_cpu.h"

#include "hardware_threads.h"

extern "C" int main(void);

#include "output.h"
#include "bufferedserial.h"

//get core_is_ready form mp.cc
extern "C" _Atomic(bool) core_is_ready[MAX_CPUS];

extern "C" {
    /* The initial stack should be placed in .data */

	char __attribute__(( aligned (16) )) os_stack[4096][MAX_CPUS] = {0xde, 0xad, 0xbe, 0xef};


	/** Initialisation stub for generic startup code */
	void init_generic();

	void arch_startup(uintptr_t hartid, uintptr_t dtb) {
		
		//arch::init_cpuid();

		uint32_t x;
		asm volatile("csrr %0, mhartid" : "=r" (x) );

		if (x == BOOT_CORE) {
		
			run_constructors();

			core_is_ready[arch::get_cpuid()] = true;
			// kout <<"BLABLAcore is ready[0] " << core_is_ready[0] << endl;

			// kout <<"core is ready[1] " << core_is_ready[1] << endl;
			// kout <<"core is ready[2] " << core_is_ready[2] << endl;
			// kout <<"core is ready[3] " << core_is_ready[3] << endl;
			// kout <<"core is ready[4] " << core_is_ready[4] << endl;

			int hartid_offset = BOOT_CORE; // This offset assumes that the bootcore is always the lowest available hartid e.g hart 1 on beaglev
			// Initialize the hart local storage (in machine.h)
			for (int i = 0; i < MAX_CPUS; i++) {
				arch::hart_local_storage[i].ipi = (uint32_t *) (CLINT_BASE + (4 * i) + (4 * hartid_offset));
				arch::hart_local_storage[i].timecmp = (uint64_t *) (CLINT_BASE + MTIMECMP_BASE + (8 * i) +  (8 * hartid_offset));
			}
		}
		debug_core << __FUNCTION__ << endl;


		//debug_core << "Main CPUID: " << arch::get_cpuid() << endl;

		// debug_core <<"BLABLAcore is ready[0] " << core_is_ready[0] << endl;

		// debug_core <<"core is ready[1] " << core_is_ready[1] << endl;
		// debug_core <<"core is ready[2] " << core_is_ready[2] << endl;
		// debug_core <<"core is ready[3] " << core_is_ready[3] << endl;
		// debug_core <<"core is ready[4] " << core_is_ready[4] << endl;

		// Enable soft interrupt source
		clear_csr(CSR_MIP, MIP_MSIP);
		//// Should be MIP_MSIE (same constant)
		set_csr(CSR_MIE, MIP_MSIP);

#ifdef CONFIG_OS_SYSTEMCALLS_WIRED

#else
		arch::Dispatcher::init();
		arch::Timer::init(1000);
#endif
		init_generic();
	}	
}

extern "C" void mainAP() {
	bool coreIsReady = core_is_ready[2];
	while (!core_is_ready[arch::get_cpuid()])
		;

	//kout << "COREISREADY: " << coreIsReady << endl;
	// wait for wakeup
	//debug_core << "HARTID: "<< arch::get_cpuid() <<", Counter: " << endl;
	main();
	//debug_core << "HHHHHHHHHHHHHHHHHHH" << endl;
	while(true);
}
