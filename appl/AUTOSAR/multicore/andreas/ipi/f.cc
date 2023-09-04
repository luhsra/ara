#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T20);
DeclareTask(T30);

DeclareEvent(E1, 1);
DeclareCounter(C1);
DeclareAlarm(A1);

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
		StartCore(OS_CORE_ID_2, &rv);
		StartCore(OS_CORE_ID_3, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
	test_trace('0');
	SetRelAlarm(A1, 500, 500);
	WaitEvent(E1);
	ChainTask(T20);
}

TASK(T10) {
	test_trace('1');
	CancelAlarm(A1);
	SetEvent(T00, E1);
	TerminateTask();
}

TASK(T20) {
	test_trace('2');
	SetEvent(T30, E1);
	ChainTask(T30);
}

TASK(T30) {
	test_trace('3');
	ShutdownAllCores(E_OK);
}

void ShutdownHook(StatusType status) {
	(void)status;
	/* The testcase has finished, check the output */
	if (GetCoreID() == OS_CORE_ID_3) {
		test_trace_assert("0123");
		test_finish();
	}
}
