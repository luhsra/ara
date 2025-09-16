#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
DeclareTask(IR);

domid_t remote_dom = 1;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(IR) {

  	ara_timing_info(3, 4);
	kout << "B2"<< endl;

	TerminateTask();
}

TASK(A) {

	kout << "A"<< endl;
	ara_timing_info(40, 50);

	wrap_evtchn_alloc_unbound(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_IR));

	ara_timing_info(40, 50);
	kout << "A2"<< endl;

	wrap_evtchn_send(channel);

	ara_timing_info(5, 10);
	kout << "A3"<< endl;

	TerminateTask();
}
