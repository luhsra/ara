#include "constructors.h"
#include "serial.h"
#include "timer.h"
#include "machine.h"
#include "dispatch.h"
#include "os/spinlock.h"
#include "boot_cpu.h"

#include "perf.h"

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
		
		
		// hartid from parameter is not dependable 
		// TODO: find out why
		uint32_t mhartid; 
		asm volatile("csrr %0, mhartid" : "=r" (mhartid) ); 

		if (mhartid == BOOT_CORE) {
		
			run_constructors();

			core_is_ready[arch::get_cpuid()] = true;

			// We assume that the bootcore is always the lowest available hartid e.g hart 1 on beaglev
			int hartid_offset = BOOT_CORE;

			// Initialize the hart local storage (in machine.h)
			for (int i = 0; i < MAX_CPUS; i++) {
				arch::hart_local_storage[i].ipi = (uint32_t *) (CLINT_BASE + (4 * i) + (4 * hartid_offset)) ;
				arch::hart_local_storage[i].timecmp = (uint64_t *) (CLINT_BASE + MTIMECMP_BASE + (8 * i) +  (8 * hartid_offset));
			}



			arch::Perf::start();

			unsigned int cycles = arch::Perf::get_cycles();
			debug_core << "Cycles: " << cycles << endl;

			arch::Perf::trace_cycles();

			int counter = 0;
			for (int i = 0; i < 10000000; i++)
			{
				counter++;
				if(counter >= 9999999) {
					debug_core << "Alsdfmost end kent1" << endl;
				}
			}
			arch::Perf::trace_cycles();
			arch::Perf::print_cycles();


			arch::Perf::reset();

			arch::Perf::stop();
			unsigned int cycles2 = arch::Perf::get_cycles();
			debug_core << "After stop 1: " << cycles2 << endl;
			unsigned int cycles3 = arch::Perf::get_cycles();
			debug_core << "After stop 2: " << cycles3 << endl;
			arch::Perf::reset();
			unsigned int cycles4 = arch::Perf::get_cycles();
			debug_core << "After reset and stop 1: " << cycles4 << endl;

			debug_core << "Trace0" << endl;
			arch::Perf::trace_counter0();

			volatile unsigned int a = 4;
			volatile unsigned int b = 5;
			arch::Perf::trace_counter0();			
			volatile unsigned int c = a * b;
			arch::Perf::trace_counter0();
			volatile unsigned int d = c / b;
			// debug_core << "Multiplication: " << c << endl;
			// debug_core << "Division: " << d << endl;

			// debug_core << "Trace1" << endl;
			arch::Perf::trace_counter0();
			// debug_core << "Trace3" << endl;
			arch::Perf::trace_counter0();
			debug_core << "Printing" << endl;
			arch::Perf::print_counter0();


			// Wake other harts from wfi after environment is set up
			for (int i = 1; i < MAX_HARTS; i++) { // No need to ipi ourselfs
				*(arch::hart_local_storage[i].ipi) = 1;
			}

		}

		debug_core << __FUNCTION__ << endl;

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
	*(arch::hart_local_storage[arch::get_cpuid()].ipi) = 0; // acknowlege the "ipi" that woke us up from wfi

	while (!core_is_ready[arch::get_cpuid()]) // wait for core start
		;	

	main();
}
