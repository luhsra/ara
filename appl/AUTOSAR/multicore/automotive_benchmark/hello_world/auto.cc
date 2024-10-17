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
DeclareAlarm(A10);
DeclareAlarm(A20);
DeclareAlarm(A50);
DeclareAlarm(A100);
DeclareAlarm(A200);
DeclareAlarm(A1000);

TEST_MAKE_OS_MAIN(StartOS(0))

unsigned version = 3;

/*
* In json:
* "ticksperbase": X
* "mincycle": X
* are not implemented!
*/



TASK(W1) {
	arch::Perf::start();
    kout << "V:" << version << " Started Perf!" << endl;
    /*kout << "Wait 1s!" << endl;
	micro_sec_wait(1000000);
    kout << "Done!" << endl;
	*/
    test_trace('W');
	TerminateTask();
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
TASK(MS2) {
    kout << "MS2" << endl;
	micro_sec_wait(4);
	test_trace('2');
	TerminateTask();
}
TASK(MS5) {
    kout << "MS5" << endl;
	micro_sec_wait(11);
	test_trace('5');
	TerminateTask();
}
TASK(MS10) {
    kout << "MS10" << endl;
	micro_sec_wait(10);
	test_trace('A');
	TerminateTask();
}
TASK(MS20) {
    kout << "MS20" << endl;
	micro_sec_wait(9);
	test_trace('B');
	TerminateTask();
}
TASK(MS50) {
    kout << "MS50" << endl;
	micro_sec_wait(18);
	test_trace('C');
	TerminateTask();
}
TASK(MS100) {
    kout << "MS100" << endl;
	micro_sec_wait(11);
	test_trace('D');
	TerminateTask();
}
TASK(MS200) {
    kout << "MS200" << endl;
	micro_sec_wait(3);
	test_trace('E');
	TerminateTask();
}
TASK(MS1000) {
    kout << "MS1000" << endl;
	micro_sec_wait(1);
	test_trace('F');
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
