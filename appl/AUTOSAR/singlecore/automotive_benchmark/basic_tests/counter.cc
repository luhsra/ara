#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(S1);
DeclareTask(MS1);
DeclareTask(MS2);
DeclareCounter(C1);
DeclareAlarm(AMS1);
DeclareAlarm(AMS2);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Testing a simple counter with 2 alarms.
 */

TASK(S1) {
	arch::Perf::start();
    kout << "Starting Coutner Test!" << endl;

    test_trace('S');
	TerminateTask();
}

TASK(MS1) {
    kout << "MS1" << endl;
	micro_sec_wait(5);
	test_trace('1');
	TerminateTask();
}

TASK(MS2) {
    kout << "MS2" << endl;
	micro_sec_wait(5);
	test_trace('2');
	TerminateTask();
}

void PreIdleHook() {

	/* The testcase has finished, check the output */
	static int cycle_count;
    cycle_count++;
    kout << "Reached Idle Hook: " << cycle_count << endl;

	if (cycle_count > 100) {
		test_trace_assert("S2111111111121111111111211111111112111111111121111111111211111111112111111111121111111111211111111112111111111121");
		test_finish();
		ShutdownMachine();
	}
}
