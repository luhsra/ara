#include "autosar/os.h"

DeclareTask(E);

int main(void) {
	StartOS(0);
}

TASK(E) {
	kout << "Hello World - E"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
