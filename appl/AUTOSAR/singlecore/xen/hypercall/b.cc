#include "autosar/os.h"
#include "events.h"

DeclareTask(B);

int main(void) {
	test_recive_event_channel(10, AUTOSAR_ISR_ISR1);
	StartOS(0);
}

// recv hypercall
ISR2(ISR1) {
	ActivateTask(B);
}

TASK(B) {
	kout << "B"<< endl;

	// TerminateTask();
	ShutdownMachine();
}


