#include "autosar/os.h"
#include "xen/events.h"

DeclareTask(C);
DeclareTask(L);
DeclareCounter(C1);
DeclareAlarm(ALARM);

extern "C" void ara_timing_info(int a, int b);

domid_t remote_dom = 1;
channel_t channel_c = 52;

int main(void) {;
	StartOS(0);
}

TASK(L) {

  	ara_timing_info(5, 5);

	wrap_evtchn_send(channel_c);
	
  	ara_timing_info(5, 5);

	TerminateTask();
}

TASK(C) {
  	ara_timing_info(45, 45);
	
	wrap_evtchn_alloc_unbound(remote_dom, channel_c, nullptr);

  	ara_timing_info(5, 5);

	TerminateTask();
}
