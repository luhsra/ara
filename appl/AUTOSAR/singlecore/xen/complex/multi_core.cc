#include "autosar/os.h"

DeclareTask(A1);
DeclareTask(A2);
DeclareTask(B);
DeclareCounter(C1);
DeclareAlarm(ALARM);

int main() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
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

static unsigned c = 0;
TASK(B) {
	kout << "Recurring B!"<< endl;

	c++;

	if (c > 3){
		kout << "Done" << endl;
		ShutdownMachine();
	}

	TerminateTask();
}
