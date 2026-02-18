#include "autosar/os.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);

int main(void) {
	StartOS(0);
}

TASK(A) {
	kout << "Hello World - A"<< endl;
	ara_timing_info(1, 2);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
