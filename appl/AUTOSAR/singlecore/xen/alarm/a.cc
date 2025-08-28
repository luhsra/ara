#include "autosar/os.h"

DeclareTask(A);
DeclareCounter(C1);
DeclareAlarm(A1);

extern "C" void ara_timing_info(int a, int b);

int main() {
	StartOS(0);
}

TASK(A) {
	kout << "Hello World"<< endl;
	ara_timing_info(50, 50);

	TerminateTask();
}

static unsigned c = 0;
void PreIdleHook() {
	c++;
	if (c > 3){
		kout << "Done" << endl;
		ShutdownMachine();

	}
}
