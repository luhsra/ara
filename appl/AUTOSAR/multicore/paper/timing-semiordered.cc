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

void fetch_sensor_a();
void fetch_sensor_b();
void compute_with_a();
void compute_with_b();
void update_status(int);


#if LOCKS_JSON
{"S1": 4}
#endif //LOCKS_JSON

// CPU 0
DeclareTask(T1); // autostart
// CPU 1
DeclareTask(T2);
DeclareTask(T3);

// CPU2
DeclareTask(T4);

DeclareSpinlock(S1);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T1) {
	GetSpinlock(S1);
	update_status(1);
	ReleaseSpinlock(S1);
	fetch_sensor_a();
	ActivateTask(T3);
	fetch_sensor_b();
	ActivateTask(T2);
	TerminateTask();
}

TASK(T3) {
	compute_with_a();
	ActivateTask(T4);
	TerminateTask();
}

TASK(T2) {
	compute_with_b();
	GetSpinlock(S1);
	update_status(2);
	ReleaseSpinlock(S1);
	TerminateTask();
}


TASK(T4) {
	GetSpinlock(S1);
	update_status(4);
	ReleaseSpinlock(S1);
	TerminateTask();
}
