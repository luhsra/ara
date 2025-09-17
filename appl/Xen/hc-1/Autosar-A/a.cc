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

  	ara_timing_info(10, 20);
	kout << "IR"<< endl;

	TerminateTask();
}


TASK(A) {

  	ara_timing_info(20, 30);
	kout << "A"<< endl;

	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_IR));

  	ara_timing_info(20, 30);
	kout << "A2"<< endl;
	
	TerminateTask();
}
