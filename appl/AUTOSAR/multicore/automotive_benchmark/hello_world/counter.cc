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
	kout << "Starting!" <<  endl;

	kout << sizeof(unsigned int) <<  endl;

	for (unsigned i = 0; i < 500; i++)
	{
		// new_wait(4200000);
		new_wait(1000000000);
	}

	kout << "max int done" << endl;
	

	test_trace('2');
	TerminateTask();
}

TASK(H3) {
	int x = 5;
	x = x*x;

	test_trace(x);
	TerminateTask();
}

void PreIdleHook() {
	/* The testcase has finished, check the output */
	static int cycle_count;
	cycle_count++;

	if (cycle_count > 3) {
		test_trace_assert("22222");
		test_finish();
		ShutdownMachine();
	}
}
