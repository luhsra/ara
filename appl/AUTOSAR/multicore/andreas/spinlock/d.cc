#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T20);
DeclareTask(T30);

DeclareSpinlock(S1);

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

int counter = 0;

TASK(T00) {
	GetSpinlock(S1);
	counter++;
	ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T10) {
	GetSpinlock(S1);
	counter++;
	ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T20) {
	GetSpinlock(S1);
	counter++;
	ReleaseSpinlock(S1);
	TerminateTask();
}

TASK(T30) {
	GetSpinlock(S1);
	counter++;
	ReleaseSpinlock(S1);
	TerminateTask();
}

void PreIdleHook() {
	if (GetCoreID() == OS_CORE_ID_MASTER) {
		usleep(100 * 1000);
		test_start();
		test_eq(counter, 4);
		test_positive_tests_eq(1);
		test_finish();
		ShutdownAllCores(E_OK);
	}
}