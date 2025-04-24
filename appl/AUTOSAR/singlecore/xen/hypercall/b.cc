#include "autosar/os.h"
#include "events.h"

DeclareTask(B);

int main(void) {
	StartOS(0);
}

TASK(B) {
	kout << "Hello B."<< endl;

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
