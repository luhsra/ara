#include "autosar/os.h"

DeclareTask(A);
DeclareTask(B);

extern "C" void ara_timing_info(int a, int b);

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
	ara_timing_info(5, 10);

	TerminateTask();
}

TASK(B) {
	kout << "Hello World Core 2"<< endl;
	ara_timing_info(20, 100);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();

	// Shutdown all cores once one idels
	// ShutdownAllCores(E_OK);
}