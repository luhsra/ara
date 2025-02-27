#include "autosar/os.h"
#include "events.h"

DeclareTask(H1);

evtchn_port_t local_port;

int main(void) {
	xen_events_init();
	local_port = bind_interdomain_event_channel(0, 42, nullptr, nullptr);
	StartOS(0);
}

TASK(H1) {
	kout << "Hello World"<< endl;

	notify_evtchn(local_port);

	TerminateTask();
}

void PreIdleHook() {
	ShutdownMachine();
}
