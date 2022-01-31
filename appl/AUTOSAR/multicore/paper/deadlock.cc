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
void ara_timing_info(int, int);

#if LOCKS_JSON
{"S1": 1, "DEADLOCK": {"S1": 1},"timed_locks": {"S1": 1, "DEADLOCK": {"S1": 1}}}
#endif //LOCKS_JSON

// CPU 0
DeclareTask(T01);
DeclareTask(T02);
// CPU 1
DeclareTask(T11);
// CPU 2
DeclareTask(T21);

DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN( StartOS(0) )

/*
 * CPU0
 */
TASK(T01) {
	ara_timing_info(1, 2);		//
	GetSpinlock(S1);
	ara_timing_info(8, 16);		//
	/* ... */
	ActivateTask(T02);
	ara_timing_info(3, 7);
	ReleaseSpinlock(S1);
	ara_timing_info(3, 4);
	TerminateTask();
}
TASK(T02) {
	ara_timing_info(3, 4);
	GetSpinlock(S1);
	ara_timing_info(3, 4);
	TerminateTask();
}

/*
 * CPU 1
 */


TASK(T11) {
	ara_timing_info(5, 10);
	ChainTask(T01);
}

/*
 * CPU 2
 */

TASK(T21) {
	TerminateTask();
}
