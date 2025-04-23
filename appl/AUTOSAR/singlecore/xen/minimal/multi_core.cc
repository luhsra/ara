#include "autosar/os.h"

DeclareTask(A);
DeclareTask(B);

int main() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TASK(A) {
	kout << "Hello World Core 1"<< endl;

	TerminateTask();
}

TASK(B) {
	kout << "Hello World Core 2"<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();

	// Shutdown all cores once one idels
	// ShutdownAllCores(E_OK);
}