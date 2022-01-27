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
extern "C" void ara_timing_info(int, int);


#if LOCKS_JSON
{"S1": 4, "timed_locks": {"S1": 0}}
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
	ara_timing_info(2, 7);
	GetSpinlock(S1);
	ara_timing_info(30, 50);
	update_status(1);
	ReleaseSpinlock(S1);
	ara_timing_info(2, 3);
	fetch_sensor_a();
	ActivateTask(T3);
	ara_timing_info(5, 8);
	fetch_sensor_b();
	ara_timing_info(10, 20);
	ActivateTask(T2);
	ara_timing_info(1, 2);
	TerminateTask();
}

TASK(T3) {
	ara_timing_info(20, 300);
	compute_with_a();
	ActivateTask(T4);
	ara_timing_info(1, 2);
	TerminateTask();
}

TASK(T2) {
	ara_timing_info(50, 100);
	compute_with_b();
	GetSpinlock(S1);
	ara_timing_info(40, 50);
	update_status(2);
	ReleaseSpinlock(S1);
	ara_timing_info(10, 20);
	TerminateTask();
}


TASK(T4) {
	ara_timing_info(2, 7);
	GetSpinlock(S1);
	ara_timing_info(10, 17);
	update_status(4);
	ReleaseSpinlock(S1);
	ara_timing_info(2, 19);
	TerminateTask();
}
