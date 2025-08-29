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

	kout << "B2 Start"<< endl;
  	ara_timing_info(10, 12);
	
	TerminateTask();
	// ShutdownMachine();
}


TASK(B) {
	kout << "B"<< endl;
  	ara_timing_info(25, 25);
	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B2));

  	ara_timing_info(25, 25);
	TerminateTask();
}
