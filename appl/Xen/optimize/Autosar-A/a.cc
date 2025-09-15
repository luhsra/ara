#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
DeclareCounter(C1);
DeclareAlarm(A1);

domid_t remote_dom = 1;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(P) {
	kout << "Periodic"<< endl;
	ara_timing_info(10, 15);
	wrap_evtchn_send(channel);
	ara_timing_info(5, 5);

	TerminateTask();
}


TASK(A) {

	kout << "A"<< endl;
	ara_timing_info(40, 50);

	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	ara_timing_info(40, 50);
	kout << "A2"<< endl;

	TerminateTask();
}
