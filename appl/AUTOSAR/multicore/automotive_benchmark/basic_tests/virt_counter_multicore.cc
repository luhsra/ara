#include "autosar/os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(S1);
DeclareTask(C2);
DeclareTask(D1);

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
 * Build a counter with a single task, to see if mstg is correct.
 */
// setup task at the beginning
TASK(S1) {
	ara_timing_info(0,1);
	arch::Perf::start();
  kout << "S C2" << endl;
	ara_timing_info(11,12);
  ActivateTask(C2);

	while (1 == 1) {
		ara_timing_info(8,9);
		kout << "1 sleep." << endl;
		micro_sec_wait(1000000);
	}
	TerminateTask();

}

// Our "counter", runs on 2nd core
TASK(C2) {
	ara_timing_info(0, 2);
	arch::Perf::start();
	kout << "C2!" << endl;
	int c = 0;
	
	while (1 == 1) {
		kout << "A: " << c << endl;
		c++;
		ara_timing_info(6,7);
		micro_sec_wait(1000000);
		ActivateTask(D1);
	}
	
	//ActivateTask(D1);
	TerminateTask();
}

TASK(D1) {
	ara_timing_info(3,4);
	kout << "Never called!" << endl;
	TerminateTask();
}

