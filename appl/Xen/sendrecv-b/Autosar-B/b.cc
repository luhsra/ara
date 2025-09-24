#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(SETUP);
DeclareTask(REG);
DeclareTask(IR);
DeclareCounter(C1);
DeclareAlarm(A1);
domid_t remote_dom = 0;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(REG) {

  	ara_timing_info(50, 100);

	TerminateTask();
}

TASK(IR) {

  	ara_timing_info(10, 20);

	TerminateTask();
}


TASK(SETUP) {

  	ara_timing_info(20, 30);
	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_IR));

  	ara_timing_info(20, 30);
	
	TerminateTask();
}
