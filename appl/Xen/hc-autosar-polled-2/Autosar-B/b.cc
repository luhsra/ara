#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
domid_t remote_dom = 0;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(B) {

  	ara_timing_info(20, 20);

	wrap_evtchn_bind_interdomain(remote_dom, channel, nullptr);

  	ara_timing_info(150, 150);

	wrap_evtchn_send(channel);

  	ara_timing_info(100, 100);

	// EventChannelState_t e;
	// e = wrap_evtchn_poll(channel);

	// if (e == PENDING_EVNT) {
  	// 	ara_timing_info(25, 25);
	// } else {
  	// 	ara_timing_info(75, 75);
	// }
	
	TerminateTask();
}
