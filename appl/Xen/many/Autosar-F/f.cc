#include "autosar/os.h"

DeclareTask(F);

int main(void) {
	StartOS(0);
}

TASK(F) {
	kout << "Hello World - F"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
