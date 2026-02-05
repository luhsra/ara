#include "autosar/os.h"

/*
* Test how singlecore SSE handles loops, also see multicore/examples/ara-loop.
* With unrolling, the analysis predicts when which are ran.
* For Ara: ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_examples_ara_loop1_cust_mod.pi4.ll
*/

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
DeclareTask(B);
DeclareTask(C);

int main(void) {
	StartOS(0);
}
TASK(B) {
	kout << "B" << endl;
	ara_timing_info(1, 1);
	TerminateTask();
}
TASK(C) {
	kout << "C" << endl;
	ara_timing_info(1, 1);
	TerminateTask();
}

TASK(A) {
	kout << "A" << endl;
	ara_timing_info(100, 100);

	int i = 0;

	if (i > 3) {
		ara_timing_info(5, 5);
		ActivateTask(B);
	} else {
		ara_timing_info(5, 5);
		ActivateTask(C);
	}
	i++;
	if (i > 3) {
		ara_timing_info(5, 5);
		ActivateTask(B);
	} else {
		ara_timing_info(5, 5);
		ActivateTask(C);
	}
	i++;
	if (i > 3) {
		ara_timing_info(5, 5);
		ActivateTask(B);
	} else {
		ara_timing_info(5, 5);
		ActivateTask(C);
	}
	i++;
	if (i > 3) {
		ara_timing_info(5, 5);
		ActivateTask(B);
	} else {
		ara_timing_info(5, 5);
		ActivateTask(C);
	}
	i++;
	if (i > 3) {
		ara_timing_info(5, 5);
		ActivateTask(B);
	} else {
		ara_timing_info(5, 5);
		ActivateTask(C);
	}
	i++;
	if (i > 3) {
		ara_timing_info(5, 5);
		ActivateTask(B);
	} else {
		ara_timing_info(5, 5);
		ActivateTask(C);
	}
	i++;

	TerminateTask();
}
