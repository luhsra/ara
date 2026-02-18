#include "autosar/os.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);

int main(void) {
	StartOS(0);
}

TASK(B) {
	kout << "Hello World - B"<< endl;
	ara_timing_info(3, 4);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
