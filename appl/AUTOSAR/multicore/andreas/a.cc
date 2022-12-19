#include "autosar/os.h"
#include "test/test.h"

DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareTask(H4);
DeclareTask(H5);

TEST_MAKE_OS_MAIN(StartOS(0))

TASK(H1) {
	test_trace('1');
	TerminateTask();
}

TASK(H2) {
	test_trace('2');
	ActivateTask(H1);
	TerminateTask();
}

TASK(H3) {
	test_trace('3');
	TerminateTask();
}

TASK(H4) {
	test_trace('4');
	ActivateTask(H3);
	TerminateTask();
}

TASK(H5) {
	test_trace('5');
	ActivateTask(H4);
	TerminateTask();
}

void PreIdleHook() {
	AUTOSAR_ShutdownOS(E_OK);
}

void ShutdownHook(StatusType status) {
	(void) status;
	/* The testcase has finished, check the output */

	kout << "test" << endl; // TODO not printed ???
	debug << "test" << endl;
	test_trace_assert("54321");
	test_finish();
}
