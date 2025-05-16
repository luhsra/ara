#include "autosar/os.h"
#include "events.h"

DeclareTask(B);
evtchn_port_t port = 42;

int main(void) {
	test_recive_event_channel(port, AUTOSAR_TASK_FUNC_B);
	StartOS(0);
}


TASK(B) {
	kout << "B"<< endl;

	// TerminateTask();
	ShutdownMachine();
}


