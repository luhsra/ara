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
{"no_timing": {"spin_states": {"S1": 0}}, "with_timing": {"spin_states": {"S1": 0}}}
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
	ara_timing_info(200, 300);
	ActivateTask(T2);
	ChainTask(T1);
}

TASK(T2) {
	ara_timing_info(10, 20);
	compute_with_a();
	TerminateTask();
}

TASK(T3) {
	ara_timing_info(30, 40);
	TerminateTask();
}


TASK(T4) {
	ara_timing_info(200, 300);
	ActivateTask(T3);
	TerminateTask();
}
