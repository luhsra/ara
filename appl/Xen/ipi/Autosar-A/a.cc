#include "autosar/os.h"
#include "test/test.h"
#include "xen/events.h"

DeclareTask(T00);

extern "C" void ara_timing_info(int a, int b);

domid_t remote_a = 0;
domid_t remote_b = 1;
domid_t remote_c = 2;
domid_t remote_d = 3;
channel_t channel_a_b = 30;
channel_t channel_a_c = 40;
channel_t channel_a_d = 50;

int main(void) {
	StartOS(0);
}

TASK(T00) {

	wrap_evtchn_alloc_unbound(remote_b, channel_a_b, nullptr);
	wrap_evtchn_alloc_unbound(remote_c, channel_a_c, nullptr);
	wrap_evtchn_alloc_unbound(remote_d, channel_a_d, nullptr);
	test_trace('0');
  	ara_timing_info(50, 50);
	// Test synchronicity
	wrap_evtchn_send(channel_a_b);
  	ara_timing_info(50, 50);
	wrap_evtchn_send(channel_a_c);
  	ara_timing_info(50, 50);
	wrap_evtchn_send(channel_a_d);
  	ara_timing_info(50, 50);
	TerminateTask();
}

