#include "autosar/os.h"

/*
* Test how singlecore SSE handles loops, also see multicore/examples/ara-loop.
* The analysis finds that both paths occur, but does not predict when which are ran.
* For Ara: ninja subprojects/ara/appl/AUTOSAR/autosar_singlecore_examples_ara_loop2_cust_mod.pi4.ll
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
	TerminateTask();
}
TASK(C) {
	kout << "C" << endl;
	TerminateTask();
}

int i = 0;  
TASK(A) {
	kout << "A" << endl;

	// this condition is not analyzed, analysis assumes both can be taken
	if (i > 5) {
		ActivateTask(B);
	} else {
		ActivateTask(C);
	}
	i++;
	
	if (i < 10) {
		ChainTask(A);
	} else {
		TerminateTask();
	}
}
