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
	ara_timing_info(1, 1);
	TerminateTask();
}
TASK(C) {
	kout << "C" << endl;
	ara_timing_info(1, 1);
	TerminateTask();
}

// global variable
int i = 0;  
TASK(A) {
	kout << "A" << endl;
	ara_timing_info(100, 100);

	// for a local variable and an impossible condition it finds the only path 
	// int i = 0;

	// for a global variable and an impossible condition, analysis assumes both branches
	if (i > 5){
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
