#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(COUNTER);
DeclareTask(WORKER);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Build a counter with a single task, to see if mstg is correct.
 */
// setup task at the beginning

// Our "counter", runs on 2nd core
TASK(COUNTER) {
	arch::Perf::start();
	ara_timing_info(0, 2);
	kout << "Counter started" << endl;
	int c = 0;
	
	while (1 == 1) {
		kout << "Counter running in loop " << c << endl;
		c++;
		ara_timing_info(10,20);
		micro_sec_wait(1000000);
		ActivateTask(WORKER);
	}
	TerminateTask();
}

TASK(WORKER) {
	arch::Perf::start();
	//ara_timing_info(5,6);
	ara_timing_info(5,15);
	kout << "Worker working!" << endl;
	TerminateTask();
}

