#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T02);
DeclareTask(T10);

DeclareAlarm(A1);
DeclareCounter(C1);

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

TASK(T00) { // PRIO 1
	test_trace('0');
	ActivateTask(T02);
	TerminateTask();
}

TASK(T01) { // PRIO 2
	test_trace('1');
	ShutdownAllCores(E_OK);
}

TASK(T02) { // PRIO 3
	test_trace('2');
	TerminateTask();
}

TASK(T10) {
	ActivateTask(T01); // IPI needed
	TerminateTask();
}

void ShutdownHook(StatusType status) {
	(void)status;
	/* The testcase has finished, check the output */
	if (GetCoreID() == OS_CORE_ID_0) {
		test_trace_assert("021");
		test_finish();
	}
}
