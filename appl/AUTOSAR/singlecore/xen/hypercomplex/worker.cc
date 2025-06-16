#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
DeclareTask(BX);
DeclareTask(BY);
DeclareTask(BZ);
domid_t sender_a = 0;
domid_t sender_loop = 2;
evtchn_port_t port_x = 42;
evtchn_port_t port_y = 45;
evtchn_port_t port_z = 48;

int main(void) {
	StartOS(0);
}

TASK(BX) {
  	ara_timing_info(15, 15);
	TerminateTask();
	// ShutdownMachine();
}

TASK(BY) {
  	ara_timing_info(25, 25);
	TerminateTask();
	// ShutdownMachine();
}

TASK(BZ) {
  	ara_timing_info(35, 35);
	TerminateTask();
	// ShutdownMachine();
}

TASK(B) {
	kout << "B"<< endl;
  	ara_timing_info(25, 25);
	test_receive_event_channel(sender_a, port_x, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_BX));
  	ara_timing_info(25, 25);
	test_receive_event_channel(sender_a, port_y, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_BY));
  	ara_timing_info(25, 25);
	test_receive_event_channel(sender_loop, port_z, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_BZ));

  	ara_timing_info(5, 5);
	TerminateTask();
}
