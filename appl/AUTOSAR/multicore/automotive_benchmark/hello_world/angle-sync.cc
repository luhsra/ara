#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

DeclareTask(W1);
DeclareTask(P1);
DeclareTask(MS1);
DeclareTask(MS2);
DeclareTask(MS5);
DeclareTask(MS10);
DeclareTask(MS20);
DeclareTask(MS50);
DeclareTask(MS100);
DeclareTask(MS200);
DeclareTask(MS1000);
DeclareCounter(C1);
DeclareAlarm(A1);
DeclareAlarm(A2);
DeclareAlarm(A5);

TEST_MAKE_OS_MAIN(StartOS(0))

unsigned version = 1;


TASK(W1) {
	arch::Perf::start();
    kout << "V:" << version << " Started Angle-Sync Test!" << endl;
    /*kout << "Wait 1s!" << endl;
	micro_sec_wait(1000000);
    kout << "Done!" << endl;
	*/
    test_trace('W');
	TerminateTask();
}

TASK(SCHED1) {

	while (true) {
		arch::Perf::get_cycles();
	}
	
}


TASK(P1) {
    kout << "P1!" << endl;
	test_trace('P');
	TerminateTask();
}


TASK(MS1) {
    kout << "MS1" << endl;
	micro_sec_wait(5);
	test_trace('1');
	TerminateTask();
}

void PreIdleHook() {

	/* The testcase has finished, check the output */
	static int cycle_count;
    cycle_count++;
    kout << "Cycle: " << cycle_count << endl;

	if (cycle_count > 100) {
		test_trace_assert("TODO");
		test_finish();
		ShutdownMachine();
	}
}
