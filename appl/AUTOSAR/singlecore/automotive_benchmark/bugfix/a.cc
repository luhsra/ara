#include "autosar/os.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(X);
DeclareTask(Y);
DeclareTask(Z);
DeclareAlarm(A1);
DeclareCounter(C1);

int main() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TASK(X) {
	ara_timing_info(100, 100);
	ActivateTask(Y);
	ara_timing_info(10, 10);
	TerminateTask();
}

TASK(Y) {
  	ara_timing_info(25, 25);
	TerminateTask();
}

TASK(Z) {
  	ara_timing_info(35, 35);
	TerminateTask();
}
