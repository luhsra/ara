#include "autosar/os.h"
#include "test/test.h"

DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareTask(H4);
DeclareTask(H5);

DeclareEvent(E1, 1);

DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN(StartOS(0))

TASK(H1) {
	test_trace('1');
	//ShutdownAllCores(E_OK);
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
	ChainTask(H1); // cross core
}

TASK(H4) {
	test_trace('4');
	ActivateTask(H3);
	TerminateTask();
}

TASK(H5) {
	test_trace('5');
	ActivateTask(H2); // cross core
	ActivateTask(H4);
	TerminateTask();
}

void PreIdleHook() {
}

void ShutdownHook(StatusType status) {
	(void) status;
	/* The testcase has finished, check the output */

	test_trace_assert("54321");
	test_finish();
}
