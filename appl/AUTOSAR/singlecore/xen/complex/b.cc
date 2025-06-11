#include "autosar/os.h"

DeclareTask(B);
DeclareCounter(C1);
DeclareAlarm(A1);

extern "C" void ara_timing_info(int a, int b);

int main(void) {;
	StartOS(0);
}

static unsigned c = 0;
TASK(B) {
	kout << "Recurring B!"<< endl;
  	ara_timing_info(15, 15);

	c++;

	if (c > 3){
		kout << "Done" << endl;
		ShutdownMachine();
	}

	TerminateTask();
}
