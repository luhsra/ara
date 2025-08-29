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

	kout << "A"<< endl;
	ara_timing_info(45, 50);

	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	ara_timing_info(50, 50);
	kout << "A2"<< endl;

	wrap_evtchn_send(channel);

	ara_timing_info(20, 20);
	kout << "A3"<< endl;

	TerminateTask();
}
