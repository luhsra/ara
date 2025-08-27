#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
DeclareTask(B2);
domid_t remote_dom = 0;
evtchn_port_t port = 42;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(B2) {

	kout << "B2 Start"<< endl;
  	ara_timing_info(10, 12);

	// Example for any other syscall
	EnableAllInterrupts();

  	ara_timing_info(4, 5);
	kout << "B2 Done"<< endl;
	
	TerminateTask();
	// ShutdownMachine();
}

// This pointer can not exist parallel to another void* !
// test_receive_event_channel(remote_dom, port, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B2));
// evtchn_cb_t cb = reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B2);

TASK(B) {
	kout << "B"<< endl;
  	ara_timing_info(25, 25);
	// test_receive_event_channel(remote_dom, port, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B2));
	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B2));

  	ara_timing_info(25, 25);
	TerminateTask();
}
