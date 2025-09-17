#include "autosar/os.h"

DeclareTask(B);
DeclareCounter(C1);
DeclareAlarm(A1);

extern "C" void ara_timing_info(int a, int b);

int main(void) {;
	StartOS(0);
}

TASK(B) {

  	ara_timing_info(7, 8);
	kout << "Recurring B!"<< endl;

	TerminateTask();
}
