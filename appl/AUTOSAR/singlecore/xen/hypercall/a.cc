#include "autosar/os.h"
#include "events.h"

DeclareTask(A);

evtchn_port_t port = 42;

int main(void) {
	// xen_events_init();
	test_sender_event_channel(port);
	StartOS(0);
}

TASK(A) {
	kout << "Hello A."<< endl;

	test_notify_evtchn(port);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
