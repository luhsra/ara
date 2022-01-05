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

typedef struct {int a;} result;

result* do_computation() {return nullptr;}

#if LOCKS_JSON
{"E1": 0}
#endif //LOCKS_JSON

DeclareTask(T1);
DeclareTask(T2);
DeclareTask(T3);
DeclareTask(T4);
DeclareTask(T5);
DeclareEvent(E1, 1);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T3) {
	/* ... */
	SetEvent(T4, E1);
	/* ... */
	ActivateTask(T4);
	ActivateTask(T2);
	TerminateTask();
}

TASK(T1) {
	/* ... */
	TerminateTask();
}



TASK(T4) {
	result* result = do_computation();
	WaitEvent(E1); //surely no wait -> no reschedule
	/* ... */
	TerminateTask();
}

TASK(T2) {
	/* ... */
	TerminateTask();
}

