#include "autosar/os.h"

DeclareTask(A1);
DeclareTask(A2);

int main(void) {
	StartOS(0);
}

TASK(A1) {
	kout << "Hello A-1."<< endl;

	ActivateTask(A2);
	TerminateTask();
}

TASK(A2) {
	kout << "A-2 done."<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
