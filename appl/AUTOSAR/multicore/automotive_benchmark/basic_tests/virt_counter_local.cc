#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(S1);
DeclareTask(C1);
DeclareTask(D1);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Build a counter with a single task, to see if mstg is correct.
 */
// setup task at the beginning
TASK(S1) {
	ara_timing_info(0,1);
	arch::Perf::start();
  kout << "Starting Perf!" << endl;
  ActivateTask(C1);
	TerminateTask();

}

// Our "counter"
TASK(C1) {

	// ara_timing_info(1,2);
	int c = 0;
	while (1 == 1) {
		kout << "Alive: " << c << endl;
		c++;
		ara_timing_info(6,7);
		micro_sec_wait(100000);
		ActivateTask(D1);
	}
	TerminateTask();
}

TASK(D1) {
	ara_timing_info(3,4);
	kout << "Never called!" << endl;
	TerminateTask();
}

