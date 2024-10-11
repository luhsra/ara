#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareAlarm(A1);
DeclareCounter(C1);

TEST_MAKE_OS_MAIN(StartOS(0))

TASK(H1) {
	test_trace('1');
	TerminateTask();
}

TASK(H2) {
	arch::Perf::start();
	kout << "Starting v5!" <<  endl;

	for (unsigned i = 0; i < 60000; i++) {
		
		micro_sec_wait(1000);
		// new_wait(0xFFFFFFFFF);
		// kout << "step done: " << i << endl;
	}

	kout << "Done!" << endl;
	

	//test_trace('2');
	TerminateTask();
}

TASK(H3) {
	int x = 5;
	x = x*x;

	test_trace(x);
	TerminateTask();
}

void PreIdleHook() {
	test_finish();
	ShutdownMachine();

	/* The testcase has finished, check the output */
	/*static int cycle_count;
	//cycle_count++;

	//if (cycle_count > 3) {
		test_trace_assert("22222");
		test_finish();
		ShutdownMachine();
	}*/
}
