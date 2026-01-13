#include "autosar/os.h"

DeclareTask(D);

int main(void) {
	StartOS(0);
}

TASK(D) {
	kout << "Hello World - D"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
