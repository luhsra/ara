#include "autosar/os.h"

DeclareTask(B);
DeclareCounter(C1);
DeclareAlarm(ALARM);


int main(void) {;
	StartOS(0);
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
