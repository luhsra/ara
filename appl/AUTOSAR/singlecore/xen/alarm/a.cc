#include "autosar/os.h"

DeclareTask(A);
DeclareCounter(C1);
DeclareAlarm(A1);

int main() {
	StartOS(0);
}

TASK(A) {
	kout << "Hello World"<< endl;

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
