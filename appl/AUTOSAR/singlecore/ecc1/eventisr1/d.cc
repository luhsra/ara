/**
 * @defgroup apps Applications
 * @brief The applications...
 */

/**
 * @file
 * @ingroup apps
 * @brief Just a simple test application
 */
#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"


DeclareTask(H1);
DeclareTask(H2);
DeclareTask(H3);
DeclareEvent(E1, 1);
DeclareEvent(E2, 2);


TEST_MAKE_OS_MAIN( StartOS(0) );

/* This test case test whether waiting in non-preemptive tasks is
   implemented properly.
 */

TASK(H1) {
	test_trace('1');
	ActivateTask(H3);
	test_trace('{');
	Machine::trigger_interrupt_from_user(37);
	test_trace('}');

	/* The testcase has finished, check the output */
	test_trace_assert("13{!>}");
	test_finish();
	ShutdownMachine();

	TerminateTask();
}

TASK(H2) {
	test_trace('-');
	TerminateTask();
}

TASK(H3) {
	test_trace('3');
	WaitEvent(E2);
	test_trace('>');
	TerminateTask();
}

ISR2(ISR1) {
	test_trace('!');
	SetEvent(H3, E2);
}

void PreIdleHook() {
}
