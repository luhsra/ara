#include "autosar/os.h"

DeclareTask(A);
DeclareTask(B);
DeclareTask(B2);

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
	kout << "A"<< endl;
	ara_timing_info(100, 100);
	ActivateTask(B2);

	ara_timing_info(20, 20);
	kout << "A2"<< endl;

	TerminateTask();
}

TASK(B) {
	kout << "B"<< endl;
  	ara_timing_info(50, 50);
	TerminateTask();
}

TASK(B2) {
	kout << "B2"<< endl;
  	ara_timing_info(40, 40);
	TerminateTask();
}
