#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
domid_t remote_dom = 0;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(IR) {

  	ara_timing_info(55, 65);
	kout << "IR"<< endl;

	TerminateTask();
}


TASK(B) {

	ara_timing_info(10, 20);
	kout << "B"<< endl;

	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	ara_timing_info(100, 110);
	kout << "B2"<< endl;

	wrap_evtchn_send(channel);

	ara_timing_info(30, 40);
	kout << "B3"<< endl;

	TerminateTask();
}
