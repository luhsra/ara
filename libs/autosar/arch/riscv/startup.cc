#include "constructors.h"
#include "timer.h"
#include "machine.h"
#include "dispatch.h"

#include "fdt.h"

#include "output.h"

extern "C" {
    /* The initial stack should be placed in .data */
	char __attribute__(( aligned (16) )) os_stack[4096] = {0xde, 0xad, 0xbe, 0xef};



	/** Initialisation stub for generic startup code */
	void init_generic();

	void arch_startup(uintptr_t hartid, uintptr_t dtb) {
		// run constructors of global objects
		run_constructors();

		// Enable soft interrupt source
		clear_csr(CSR_MIP, MIP_MSIP);
		//// Should be MIP_MSIE (same constant)
		set_csr(CSR_MIE, MIP_MSIP);

        // kout << "Hart ID: " << hartid << " DTB: " << dtb << endl;

        // arch::fdt_print(dtb);
        arch::query_mem(dtb);
        arch::query_harts(dtb);
        arch::query_clint(dtb);

#ifdef CONFIG_OS_SYSTEMCALLS_WIRED
		// arch::Timer::init is called in StartOS
#else
		arch::Dispatcher::init();
		arch::Timer::init();
#endif

		init_generic();
	}
}
