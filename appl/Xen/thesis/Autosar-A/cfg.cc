#include "autosar/os.h"

DeclareTask(A);
DeclareTask(B);

extern "C" void ara_timing_info(int a, int b);

int main() {
	StartOS(0);
}

TASK(A) {
	kout << "Hello World"<< endl;
	ara_timing_info(5, 10);
	ActivateTask(B);
}

TASK(B) {
	kout << "Hello World 2"<< endl;
	ara_timing_info(20, 100);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}