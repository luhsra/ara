#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T02);
DeclareTask(T10);

DeclareEvent(E1, 1);

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
	test_trace('0');
	ActivateTask(T01);
	ActivateTask(T02);
	ShutdownAllCores(E_OK);
}

TASK(T01) {
	test_trace('1');
	WaitEvent(E1); // wait for IPI
	TerminateTask();
}

TASK(T02) {
	test_trace('2');
	ActivateTask(T10);
	TerminateTask();
}

TASK(T10) {
	SetEvent(T01, E1); // IPI can be avoided
	TerminateTask();
}

void ShutdownHook(StatusType status) {
	(void)status;
	/* The testcase has finished, check the output */
	if (GetCoreID() == OS_CORE_ID_0) {
		test_trace_assert("012");
		test_finish();
	}
}
