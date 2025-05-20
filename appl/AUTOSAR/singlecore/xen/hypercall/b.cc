#include "autosar/os.h"
#include "xen/events.h"

DeclareTask(B);
DeclareTask(B2);
evtchn_port_t port = 42;

int main(void) {
	StartOS(0);
}

TASK(B) {
	kout << "B"<< endl;
	test_recive_event_channel(port, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B));

	TerminateTask();
}



TASK(B2) {
	kout << "B2"<< endl;

	// TerminateTask();
	ShutdownMachine();
}
