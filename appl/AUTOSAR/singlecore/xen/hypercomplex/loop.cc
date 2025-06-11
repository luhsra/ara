#include "autosar/os.h"
#include "xen/events.h"

DeclareTask(C);
DeclareCounter(C1);
DeclareAlarm(ALARM);

extern "C" void ara_timing_info(int a, int b);

domid_t remote_dom = 1;
evtchn_port_t port_z = 48;

int main(void) {;
	StartOS(0);
}

static unsigned c = 0;
TASK(L) {

	c++;
  	ara_timing_info(5, 5);
	test_notify_evtchn(remote_dom, port_z);

	if (c > 10){
		kout << "Done" << endl;
		ShutdownMachine();
	}

	TerminateTask();
}

TASK(C) {
  	ara_timing_info(45, 45);
	test_send_event_channel(remote_dom, port_z);

  	ara_timing_info(5, 5);
	TerminateTask();
}
