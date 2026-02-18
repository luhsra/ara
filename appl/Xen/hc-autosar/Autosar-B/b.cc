#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
DeclareTask(IR);
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

  	ara_timing_info(15, 25);
	kout << "B"<< endl;

	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_IR));

  	ara_timing_info(35, 45);
	kout << "B2"<< endl;
	
	TerminateTask();
}
