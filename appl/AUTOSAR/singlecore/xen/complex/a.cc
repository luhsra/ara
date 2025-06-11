#include "autosar/os.h"

DeclareTask(A1);
DeclareTask(A2);

extern "C" void ara_timing_info(int a, int b);

int main(void) {
	StartOS(0);
}

TASK(A1) {
	kout << "Hello A-1."<< endl;
  	ara_timing_info(5, 5);

	ActivateTask(A2);
  	ara_timing_info(5, 5);
	TerminateTask();
}

TASK(A2) {
	kout << "A-2 done."<< endl;
  	ara_timing_info(10, 10);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
