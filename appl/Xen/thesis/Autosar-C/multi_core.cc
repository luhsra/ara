#include "autosar/os.h"

DeclareTask(A1);
DeclareTask(A2);
DeclareTask(B);
DeclareCounter(C1);
DeclareAlarm(ALARM);

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

TASK(A1) {

  	ara_timing_info(5, 5);
	kout << "Hello A-1."<< endl;

	ChainTask(A2);
}

TASK(A2) {
	
  	ara_timing_info(20, 20);
	kout << "A-2 done."<< endl;

	TerminateTask();
}

TASK(B) {

  	ara_timing_info(7, 8);
	kout << "Recurring B!"<< endl;

	TerminateTask();
}
