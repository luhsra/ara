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
	kout << "Starting wait!" <<  endl;
	wait(0,1);
	kout << "Done 0!" << endl;
	wait(1000000,1);
	kout << "Done 1000000!" << endl;
	ara_timing_info(2,3);
	kout << "ara_timing_info 2!" << endl;
	ara_timing_info(5,10);
	kout << "ara_timing_info 5!" << endl;

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

	if (cycle_count > 5) {
		test_trace_assert("22222");
		test_finish();
		ShutdownMachine();
	}
}
