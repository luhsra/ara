#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T01);
DeclareTask(T11);

DeclareSpinlock(S1);

void ara_timing_info(int, int);

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
	GetSpinlock(S1);
	ActivateTask(T10);
	ara_timing_info(1,2);
	test_trace('1');
	ReleaseSpinlock(S1);
	TerminateTask();
	//ShutdownOS(E_OK);
}

TASK(T01) { TerminateTask(); }

TASK(T10) {
	ara_timing_info(10,20);
	GetSpinlock(S1);
	test_trace('2');
	ReleaseSpinlock(S1);
	ShutdownOS(E_OK);
}

TASK(T11) { TerminateTask(); }

void ShutdownHook(StatusType status) {
	(void)status;
	/* The testcase has finished, check the output */
	if (GetCoreID() == OS_CORE_ID_1) {
		test_trace_assert("12");
		test_finish();
	}
}
