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

	ara_timing_info(40, 50);
	kout << "B"<< endl;

	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	ara_timing_info(40, 50);
	kout << "B2"<< endl;

	wrap_evtchn_send(channel);

	ara_timing_info(20, 30);
	kout << "B3"<< endl;

	TerminateTask();
}
