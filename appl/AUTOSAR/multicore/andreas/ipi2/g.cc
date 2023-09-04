#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);

struct timespec t1, t2;

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
	TerminateTask();
}

TASK(T01) {
	test_trace('1');
	while (true)
		; /* block cpu 0*/
	TerminateTask();
}

TASK(T10) {
	ActivateTask(T00); // IPI not needed
	test_trace('2');
	ShutdownOS(E_OK);
}

void StartupHook() {
	if (GetCoreID() == OS_CORE_ID_1) {
		clock_gettime(CLOCK_REALTIME, &t1);
	}
}
void ShutdownHook(StatusType status) {
	if (GetCoreID() == OS_CORE_ID_1) {
		clock_gettime(CLOCK_REALTIME, &t2);
		int diff = t2.tv_nsec - t1.tv_nsec;
		kout << diff << " ns" << endl;
		test_trace_assert("12");
		test_finish();
		ShutdownMachine();
	}
}
