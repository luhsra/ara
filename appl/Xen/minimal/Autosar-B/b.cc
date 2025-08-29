#include "autosar/os.h"

DeclareTask(B);

int main(void) {
	StartOS(0);
}

TASK(B) {
	kout << "Hello World - b"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
