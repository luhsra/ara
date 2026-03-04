#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(S1);
DeclareTask(MS1);
DeclareCounter(C1);
DeclareAlarm(AMS1);

TEST_MAKE_OS_MAIN(StartOS(0))

/**
 * Testing a simple counter.
 * for multisee timing == false
 * No different, since taskgroup does not help with 1 task
 */

TASK(S1) {
	arch::Perf::start();
  kout << "Starting Coutner Test!" << endl;
  test_trace('S');
	TerminateTask();
}

TASK(MS1) {
  kout << "MS1" << endl;
	test_trace('1');
	TerminateTask();
}

void PreIdleHook() {

	/* The testcase has finished, check the output */
	static int cycle_count;
  cycle_count++;
  kout << "Reached Idle Hook: " << cycle_count << endl;

	if (cycle_count > 10) {
		test_finish();
		ShutdownMachine();
	}
}
