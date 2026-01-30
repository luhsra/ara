#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
DeclareTask(B);
DeclareTask(C);
domid_t remote_dom = 1;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(B) {
	// kout << "B" << endl;
	TerminateTask();
}
TASK(C) {
	// kout << "C" << endl;
	TerminateTask();
}

TASK(A) {

	ara_timing_info(10, 10);

	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

  	ara_timing_info(100, 100);

	EventChannelState_t e;
	e = wrap_evtchn_poll(channel, IS_BRANCH);

	if (e == PENDING_EVNT) {
  		ara_timing_info(12, 12);
  		ara_timing_info(1, 1);
		ActivateTask(B);
	} else {
  		ara_timing_info(15, 15);
		ActivateTask(C);
  		ara_timing_info(2, 2);
	}
	
  	ara_timing_info(100, 100);

	e = wrap_evtchn_poll(channel, IS_BRANCH);
	if (e == PENDING_EVNT) {
  		ara_timing_info(12, 12);
		ActivateTask(B);
  		ara_timing_info(1, 1);
	} else {
  		ara_timing_info(15, 15);
		ActivateTask(C);
  		ara_timing_info(2, 2);
	}

  	ara_timing_info(5, 5);

	TerminateTask();
}
