#include "autosar/os.h"

DeclareTask(A);

int main(void) {
	StartOS(0);
}

TASK(A) {
	kout << "Hello World - A"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
