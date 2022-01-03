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


// Test memory protection (spanning over more than one 4k page in x86)
//volatile int testme[1024*4*10] __attribute__ ((section (".data.Handler12")));

DeclareTask(T00);
DeclareTask(T10);
DeclareTask(T11);
DeclareTask(T20);
DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T00) {
	ActivateTask(T10);
	while(1) {
		GetSpinlock(S1);
		ReleaseSpinlock(S1);
	}
	TerminateTask();
}

TASK(T20) {
	ActivateTask(T11);
	while(1) {
		GetSpinlock(S1);
		ReleaseSpinlock(S1);
	}
	TerminateTask();
}

TASK(T10) {
	while(1) {
		GetSpinlock(S1);
		ReleaseSpinlock(S1);
	}
	TerminateTask();
}

TASK(T11) {
	TerminateTask();
}
