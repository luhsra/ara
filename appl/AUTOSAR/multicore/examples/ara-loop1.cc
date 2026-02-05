#include "autosar/os.h"

/*
* Test how MultiSSE handles loops, also see singlecore/examples/ara-loop.
* Still get warning: `Found a previously resumed state that is continued. This is not supported.`
* For Ara: ninja subprojects/ara/appl/AUTOSAR/autosar_multicore_examples_ara_loop1_cust_mod.pi4.ll
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

	for (int i = 0; i < 10; i++) {
		// this condition is analyzed, only possible conditions are considered
		if (i > 5) {
			ara_timing_info(5, 5);
			ActivateTask(B);
		} else {
			ara_timing_info(5, 5);
			ActivateTask(C);
		}
	}
	
	TerminateTask();
}
