#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
domid_t remote_dom = 1;
evtchn_port_t port_x = 42;
evtchn_port_t port_y = 45;


int main(void) {
	StartOS(0);
}

TASK(A) {
	ara_timing_info(100, 100);
	test_send_event_channel(remote_dom, port_x);
	ara_timing_info(100, 100);
	test_send_event_channel(remote_dom, port_y);

	ara_timing_info(250, 250);
	test_notify_evtchn(remote_dom, port_x);

	ara_timing_info(250, 250);
	test_notify_evtchn(remote_dom, port_y);

	ara_timing_info(250, 250);
	test_notify_evtchn(remote_dom, port_x);

	ara_timing_info(50, 50);
	TerminateTask();
	// ShutdownMachine();
}
