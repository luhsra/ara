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
int c = 0;
// Our "counter", runs on 2nd core
TASK(COUNTER) {
	arch::Perf::start();
	ara_timing_info(90, 90);
	kout << "Counter started" << endl;
	int res;	

	while (1 == 1) {
		c++;
		//kout << "Counter running in loop " << c << endl;
		ara_timing_info(10,10);
    res = ActivateTask(WORKER);
		/*
    if (res == StatusType::E_OK)  {
        kout << "+" << endl;
		}
		else {
			kout << "-" << endl;
		}*/
		micro_sec_wait(1000000);
	}
	TerminateTask();
}

TASK(WORKER) {
	arch::Perf::start();
	// VAR A: Worker always slower
	ara_timing_info(5,6);

	// VAR B: Worker could be faster or slower
	//ara_timing_info(15,15)<< c ;
	kout << "Worker working:" << c << endl;
	TerminateTask();
}

