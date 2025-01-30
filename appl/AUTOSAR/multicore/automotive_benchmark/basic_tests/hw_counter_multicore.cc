#include "autosar/os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(WORKER);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Build a counter with a single task, to see if mstg is correct.
 */


TASK(WORKER) {
	arch::Perf::start();

	// VAR A: Worker always slower
	ara_timing_info(5,6);

	// VAR B: Worker could be faster or slower
	//ara_timing_info(5,15);

	kout << "Worker working!" << endl;
	TerminateTask();
}

