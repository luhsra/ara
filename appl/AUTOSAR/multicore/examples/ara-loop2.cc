#include "autosar/os.h"

/*
* Test how MultiSSE handles loops, also see singlecore/examples/ara-loop.
* Still get warning: `Found a previously resumed state that is continued. This is not supported.`
* For Ara: ninja subprojects/ara/appl/AUTOSAR/autosar_multicore_examples_ara_loop2_cust_mod.pi4.ll
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

int i = 0;
TASK(A) {
	kout << "A" << endl;
	ara_timing_info(100, 100);

	// this condition is not analyzed, analysis assumes both can be taken
	if (i > 5) {
		ara_timing_info(5, 5);
		ActivateTask(B);
	} else {
		ara_timing_info(5, 5);
		ActivateTask(C);
	}
	i++;
	
	if (i < 10) {
		ChainTask(A);
	} else {
		TerminateTask();
	}
}
