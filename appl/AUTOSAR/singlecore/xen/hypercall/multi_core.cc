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
	kout << "A"<< endl;

	ActivateTask(B);
	TerminateTask();
}

TASK(B) {
	kout << "B"<< endl;

	TerminateTask();
}


