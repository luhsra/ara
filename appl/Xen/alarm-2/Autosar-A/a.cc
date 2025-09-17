#include "autosar/os.h"

DeclareTask(A1);
DeclareTask(A2);

extern "C" void ara_timing_info(int a, int b);

int main(void) {
	StartOS(0);
}

TASK(A1) {

  	ara_timing_info(5, 5);
	kout << "Hello A-1."<< endl;

	ChainTask(A2);
}

TASK(A2) {

  	ara_timing_info(20, 20);
	kout << "A-2 done."<< endl;

	TerminateTask();
}
