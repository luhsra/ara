#include "autosar/os.h"
#include "xen/events.h"

DeclareTask(B);
DeclareTask(B2);
evtchn_port_t port = 42;

extern "C" void ara_timing_info(int a, int b);

int main(void) {
	StartOS(0);
}

TASK(B) {
	kout << "B"<< endl;
  	ara_timing_info(25, 25);
	test_receive_event_channel(port, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_B));

  	ara_timing_info(25, 25);
	TerminateTask();
}

TASK(B2) {
	kout << "B2"<< endl;

  	ara_timing_info(40, 40);
	// TerminateTask();
	ShutdownMachine();
}
