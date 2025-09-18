#include "autosar/os.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T20);
DeclareTask(T30);

extern "C" void ara_timing_info(int a, int b);

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
  	ara_timing_info(50, 50);
	// Test synchronicity
	ActivateTask(T10);
  	ara_timing_info(50, 50);
	ActivateTask(T20);
  	ara_timing_info(50, 50);
	ActivateTask(T30);
  	ara_timing_info(50, 50);
	TerminateTask();
}

TASK(T10) {
	test_trace('1');
  	ara_timing_info(30, 30);
	TerminateTask();
}

TASK(T20) {
	test_trace('2');
  	ara_timing_info(30, 30);
	TerminateTask();
}

TASK(T30) {
	test_trace('3');
  	ara_timing_info(30, 30);
	TerminateTask();
}

// void ShutdownHook(StatusType status) {
// 	(void)status;
// 	/* The testcase has finished, check the output */
// 	if (GetCoreID() == OS_CORE_ID_3) {
// 		test_trace_assert("0123");
// 		test_finish();
// 	}
// }
