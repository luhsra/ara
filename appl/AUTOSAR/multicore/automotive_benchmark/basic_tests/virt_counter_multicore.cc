#include "autosar/os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(COUNTER);
DeclareTask(WORKER);

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

/**
 * Build a virt counter with a single task, to see if mstg is correct.
 */

// Our "counter", runs on 2nd core
TASK(COUNTER) {
	arch::Perf::start();
	ara_timing_info(100, 120);
	debug_core << "Counter started" << endl;
	int c = 0;
	

	while (1 == 1) {
		debug_core << "Counter running in loop " << c << endl;
		c++;
		ara_timing_info(10,20);
		micro_sec_wait(1000000);
		ActivateTask(WORKER);
	}
	TerminateTask();
}

TASK(WORKER) {
	arch::Perf::start();
	// VAR A: Worker always slower
	ara_timing_info(5,6);



	// VAR B: Worker could be faster or slower
	//ara_timing_info(5,15);
	debug_core << "Worker working!" << endl;
	TerminateTask();
}

