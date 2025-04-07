#include "autosar/os.h"
#include "events.h"

DeclareTask(B);
DeclareTask(B2);

evtchn_port_t local_port;

int main() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		xen_events_init();
		local_port = bind_interdomain_event_channel(0, 42, nullptr, nullptr);
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TASK(B) {
	kout << "Hello World"<< endl;

	notify_evtchn(local_port);
	ActivateTask(B2);
	TerminateTask();
}

TASK(B2) {
	kout << "From Core 2"<< endl;

	notify_evtchn(local_port);

	ShutdownAllCores(E_OK);
}
