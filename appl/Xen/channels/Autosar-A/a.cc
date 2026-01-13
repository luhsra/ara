#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
domid_t remote_dom = 1;
channel_t channel_a = 50;
channel_t channel_b = 51;


int main(void) {
	StartOS(0);
}

TASK(A) {

	ara_timing_info(100, 100);

	wrap_evtchn_alloc_unbound(remote_dom, channel_a, nullptr);

	ara_timing_info(100, 100);
	wrap_evtchn_alloc_unbound(remote_dom, channel_b, nullptr);

	ara_timing_info(250, 250);

	wrap_evtchn_send(channel_a);

	ara_timing_info(250, 250);

	wrap_evtchn_send(channel_b);

	ara_timing_info(250, 250);

	wrap_evtchn_send(channel_a);

	ara_timing_info(50, 50);

	TerminateTask();
}
