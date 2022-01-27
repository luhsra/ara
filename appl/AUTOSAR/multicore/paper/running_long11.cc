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
void prepare();
void ara_timing_info(int, int);

#if LOCKS_JSON
{"S1": 0, "timed_locks": {"S1": 0}}
#endif //LOCKS_JSON

// CPU 0
DeclareTask(T01);
DeclareTask(T02);
// CPU 1
DeclareTask(T11); // autostart
// CPU 2
DeclareTask(T21);

DeclareSpinlock(S1);
DeclareSpinlock(S2);

TEST_MAKE_OS_MAIN( StartOS(0) )

/* 
 * CPU0
 */
TASK(T01) {
	ara_timing_info(1, 2);
	GetSpinlock(S1);
	ara_timing_info(5, 10);
	/* ... some computation */
	ReleaseSpinlock(S1);
	ara_timing_info(2, 4);
	TerminateTask();
}

TASK(T02) {
	ara_timing_info(60, 80);
	/* ... some computation ... */
	TerminateTask();
}

/*
 * CPU 1
 */


TASK(T11) {
	ara_timing_info(1, 2);		// 
	/* ... some computation ... */
	GetSpinlock(S1);
	ara_timing_info(8, 16);		// 
	/* ... */
	ReleaseSpinlock(S1);
	ara_timing_info(10, 20);		// 
	ActivateTask(T02);
	ara_timing_info(10, 20);	// 
	ActivateTask(T01);
	ara_timing_info(20, 30);	// 
	ActivateTask(T21);
	ara_timing_info(40, 40);
	TerminateTask();
}

/*
 * CPU 2
 */
TASK(T21) {
	// ara_timing_info(1, 2);
	// /* ... some computation ... */
	// GetSpinlock(S1);
	// ara_timing_info(8, 16);
	// /* ... */
	// ReleaseSpinlock(S1);
	ara_timing_info(1, 2);
	TerminateTask();
}
