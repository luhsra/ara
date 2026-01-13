#include "autosar/os.h"

DeclareTask(C);

int main(void) {
	StartOS(0);
}

TASK(C) {
	kout << "Hello World - C"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
