#include "autosar/os.h"
#include "test/test.h"

DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareTask(H4);
DeclareTask(H5);

DeclareAlarm(A1);
DeclareCounter(C1);
DeclareEvent(E1, 1);

DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN(StartOS(0))

void alarm_test()
{
	test_trace('1');
}

TASK(H1) {

    TickType ticks;
    GetAlarm(A1, &ticks);
	debug_core << ticks << endl;
	ShutdownAllCores(E_OK);
	TerminateTask();
}

TASK(H2) {
	WaitEvent(E1);
	test_trace('2');
	TerminateTask();
}

TASK(H3) {
	test_trace('3');
	SetEvent(H2, E1); // cross core
	TerminateTask();
}

TASK(H4) {
	test_trace('4');
	ChainTask(H3); // cross core
}

TASK(H5) {
	Machine::trigger_interrupt_from_user(SIGTRAP);
	ActivateTask(H2); // cross core
	ActivateTask(H4);
	TerminateTask();
}

ISR2(ISR1) {
	test_trace('5');
}

ALARMCALLBACK(A1) {
	alarm_test();
}

void PreIdleHook() {
}

void ShutdownHook(StatusType status) {
	(void) status;
	/* The testcase has finished, check the output */

	test_trace_assert("54321");
	test_finish();
}
