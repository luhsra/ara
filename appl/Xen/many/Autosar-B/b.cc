#include "autosar/os.h"

DeclareTask(B);

int main(void) {
	StartOS(0);
}

TASK(B) {
	kout << "Hello World - B"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
