#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"

typedef struct {int a;} result;

result* do_computation() {return nullptr;}
void ara_timing_info(int, int);

// CPU 0
DeclareTask(T01); // autostart
// CPU 1
DeclareTask(T11); // autostart
DeclareTask(T12);
DeclareTask(T13);
// CPU 2
DeclareTask(T21); // autostart

TEST_MAKE_OS_MAIN( StartOS(0) )

/* 
 * CPU0
 */
TASK(T01) {
	ara_timing_info(1, 2);
	ActivateTask(T12);
	ara_timing_info(1, 2);
	TerminateTask();
}

/*
 * CPU 1
 */

TASK(T11) {
	ara_timing_info(60, 80);
	TerminateTask();
}


TASK(T12) {
	ara_timing_info(1, 2);		// 
	TerminateTask();
}

TASK(T13) {
	ara_timing_info(60, 80);		// 
	TerminateTask();
}

/*
 * CPU 2
 */
TASK(T21) {
	ara_timing_info(10, 12);
	ActivateTask(T13);
	ara_timing_info(1, 2);
	TerminateTask();
}
