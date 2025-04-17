#include "autosar/os.h"
// #include "events.h"

DeclareTask(A);
DeclareTask(B);
DeclareTask(B2);
DeclareCounter(C1);
DeclareAlarm(A1);

// evtchn_port_t local_port;

int main() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		// xen_events_init();
		// local_port = bind_interdomain_event_channel(0, 42, nullptr, nullptr);
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TASK(A) {
	kout << "Hello World"<< endl;

	// notify_evtchn(local_port);
	// ActivateTask(B2);
	TerminateTask();
}



TASK(B) {
	kout << "From Core 2"<< endl;

	// notify_evtchn(local_port);

	TerminateTask();
}



TASK(B2) {
	kout << "Recurring B2!"<< endl;

	// notify_evtchn(local_port);

	TerminateTask();
}

static unsigned c = 0;
void PreIdleHook() {
	c++;
	if (c > 3){
		kout << "B done" << endl;
		ShutdownMachine();

	}
}
