#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
domid_t remote_dom = 1;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(A) {

	ara_timing_info(10, 20);
	kout << "A"<< endl;

	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	ara_timing_info(100, 110);
	kout << "A2"<< endl;

	wrap_evtchn_send(channel);

	ara_timing_info(30, 40);
	kout << "A3"<< endl;

	TerminateTask();
}
