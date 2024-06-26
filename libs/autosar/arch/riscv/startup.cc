#include "constructors.h"
#include "serial.h"
#include "timer.h"
#include "machine.h"
#include "dispatch.h"

#include "hardware_threads.h"

extern "C" int main(void);

#include "output.h"

//get core_is_ready form mp.cc
extern "C" _Atomic(bool) core_is_ready[MAX_CPUS];

//array indicator that the core is ready to start
//bool core_ready[MAX_CPUS] = {false};

extern "C" {
    /* The initial stack should be placed in .data */
	char __attribute__(( aligned (16) )) os_stack[4096][MAX_CPUS] = {0xde, 0xad, 0xbe, 0xef};


	/** Initialisation stub for generic startup code */
	void init_generic();

	void arch_startup(uintptr_t hartid, uintptr_t dtb) {
		debug_core << __FUNCTION__ << endl;
		// run constructors of global objects
		
		run_constructors();

		// Enable soft interrupt source
		clear_csr(CSR_MIP, MIP_MSIP);
		//// Should be MIP_MSIE (same constant)
		set_csr(CSR_MIE, MIP_MSIP);

        // kout << "Hart ID: " << hartid << " DTB: " << dtb << endl;

		// TODO statically define addresses
        // arch::fdt_print(dtb);
        //arch::query_mem(dtb);
        //arch::query_harts(dtb);
        //arch::query_clint(dtb);

#ifdef CONFIG_OS_SYSTEMCALLS_WIRED
		// arch::Timer::init is called in StartOS
#else
		arch::Dispatcher::init();
		// TODO enable timer
		arch::Timer::init(1000);
#endif

		init_generic();
	}
}

extern "C" void mainAP() {

	kout << 'x' << endl; //arch::get_cpuid() << endl;
	while (!core_is_ready[arch::get_cpuid()]) {
		//kout << 'x' << endl;
	}
	main();

}