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

  	ara_timing_info(20, 30);
	kout << "B2"<< endl;

	wrap_evtchn_send(channel);
  	ara_timing_info(5, 10);

	TerminateTask();
}


TASK(B) {

  	ara_timing_info(20, 30);
	kout << "B"<< endl;

	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_IR));

  	ara_timing_info(20, 30);
	
	TerminateTask();
}
