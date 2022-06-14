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
DeclareTask(T11);
DeclareTask(T21);
DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T01) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T11);
}

TASK(T11) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	ChainTask(T21);
}

TASK(T21) {
	GetSpinlock(S1);
	ReleaseSpinlock(S1);
	TerminateTask();
}
