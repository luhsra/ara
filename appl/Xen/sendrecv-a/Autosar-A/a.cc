#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(SEND);
DeclareTask(SETUP);
DeclareCounter(C1);
DeclareAlarm(A1);

domid_t remote_dom = 1;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(SETUP) {

	ara_timing_info(40, 50);

	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	ara_timing_info(40, 50);
	TerminateTask();
}

TASK(SEND) {

	ara_timing_info(20, 30);
	wrap_evtchn_send(channel);
	ara_timing_info(20, 30);
	
	TerminateTask();
}
