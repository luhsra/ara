#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
evtchn_port_t port = 42;

int main(void) {
	StartOS(0);
}

TASK(A) {
	kout << "A"<< endl;
	ara_timing_info(50, 50);
	test_send_event_channel(port);

	ara_timing_info(50, 50);
	kout << "A2"<< endl;
	test_notify_evtchn(port);

	ara_timing_info(20, 20);
	kout << "A3"<< endl;
	TerminateTask();
	// ShutdownMachine();
}
