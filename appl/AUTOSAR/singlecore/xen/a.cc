#include "autosar/os.h"
// #include "events.h"

DeclareTask(A);

// evtchn_port_t local_port;

int main(void) {
	// xen_events_init();
	// local_port = bind_interdomain_event_channel(0, 42, nullptr, nullptr);
	StartOS(0);
}

TASK(A) {
	// kout << "Hello World"<< endl;

	// notify_evtchn(local_port);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
