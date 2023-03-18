#include "autosar/os.h"
#include "test/test.h"

DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareTask(H4);
DeclareTask(H5);
DeclareResource(RES_SCHEDULER);
DeclareResource(R234);
DeclareResource(R345);


TEST_MAKE_OS_MAIN(StartOS(0))

TASK(H1) {
	TerminateTask();
}

TASK(H2) {
	test_trace('2');
	TerminateTask();
}

TASK(H3) {
	test_trace('3');
	TerminateTask();
}

TASK(H4) {
	TerminateTask();
}


TASK(H5) {
	test_trace('5');
	GetResource(R345);
	test_trace('{');
	GetResource(R234);
	test_trace('[');
	ReleaseResource(R234);
	test_trace(']');
	ActivateTask(H2);
	ActivateTask(H4);
	ReleaseResource(R345);
	test_trace('}');
	TerminateTask();
}

void PreIdleHook() {
	/* The testcase has finished, check the output */
	test_start_check();
	test_trace_assert("5{[]2}");
	test_finish();
	ShutdownMachine();
}
