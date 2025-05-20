#include "autosar/os.h"
#include "xen/events.h"


DeclareTask(A);
evtchn_port_t port = 42;

int main(void) {
	StartOS(0);
}



TASK(A) {
	kout << "A"<< endl;
	test_sender_event_channel(port);

	kout << "A2"<< endl;
	test_notify_evtchn(port);
	ActivateTask(A);

	kout << "A3"<< endl;
	// TerminateTask();
	ShutdownMachine();
}
