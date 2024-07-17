#include "constructors.h"
#include "serial.h"
#include "timer.h"
#include "machine.h"
#include "dispatch.h"
#include "os/spinlock.h"

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
		

		if (arch::get_cpuid() == 0) {
		
			run_constructors();

			core_is_ready[0] = true;
			
			// Initialize the hart local storage (in machine.h)
			for (int i = 0; i < MAX_CPUS; i++) {
				arch::hart_local_storage[i].ipi = (uint32_t *) (CLINT_BASE + (4 * i));
				arch::hart_local_storage[i].timecmp = (uint64_t *) (CLINT_BASE + MTIMECMP_BASE + (8 * i));
			}
		}
		debug_core << __FUNCTION__ << endl;

		// Enable soft interrupt source
		clear_csr(CSR_MIP, MIP_MSIP);
		//// Should be MIP_MSIE (same constant)
		set_csr(CSR_MIE, MIP_MSIP);

        // kout << "Hart ID: " << hartid << " DTB: " << dtb << endl;

#ifdef CONFIG_OS_SYSTEMCALLS_WIRED

#else
		arch::Dispatcher::init();
		arch::Timer::init(1000);
#endif
		init_generic();
	}
}

extern "C" void mainAP() {

	while (!core_is_ready[arch::get_cpuid()]); // wait for wakeup
	main();

}
