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


DeclareTask(T01);
DeclareTask(T02);
DeclareTask(T11);
DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T01) {
	TerminateTask();
}

TASK(T02) {
	ActivateTask(T11);
	TerminateTask();
}

TASK(T11) {
	TerminateTask();
}
