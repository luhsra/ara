#include "autosar/os.h"
// #include "events.h"

DeclareTask(B);
DeclareTask(B2);
DeclareCounter(C1);
DeclareAlarm(A1);

// evtchn_port_t local_port;

int main(void) {
	// xen_events_init();
	// local_port = bind_interdomain_event_channel(0, 42, nullptr, nullptr);
	StartOS(0);
}

TASK(B) {
	kout << "Hello B."<< endl;

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
