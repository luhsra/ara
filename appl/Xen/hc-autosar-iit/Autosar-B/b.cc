#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
DeclareTask(B2);
domid_t remote_dom = 0;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(B2) {

  	ara_timing_info(10, 20);
	kout << "B2"<< endl;

	TerminateTask();
}


TASK(B) {

  	ara_timing_info(20, 30);
	kout << "B"<< endl;

	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B2));

  	ara_timing_info(20, 30);
	
	TerminateTask();
}
