#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(B);
DeclareTask(BX);
DeclareTask(BY);
DeclareTask(BZ);
domid_t sender_a = 0;
domid_t sender_c = 2;
channel_t channel_a = 50;
channel_t channel_b = 51;
channel_t channel_c = 52;

int main(void) {
	StartOS(0);
}

TASK(BX) {
  	ara_timing_info(15, 15);

	TerminateTask();
}

TASK(BY) {
  	ara_timing_info(7, 8);

	// Example for any other syscall
	EnableAllInterrupts();

  	ara_timing_info(9, 10);

	TerminateTask();
}

TASK(BZ) {
  	ara_timing_info(35, 35);

	TerminateTask();
}

TASK(B) {
  	ara_timing_info(25, 25);
	kout << "B"<< endl;

	wrap_evtchn_bind_interdomain(sender_a, channel_a, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_BX));

  	ara_timing_info(25, 25);

	wrap_evtchn_bind_interdomain(sender_a, channel_b, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_BY));

  	ara_timing_info(25, 25);

	wrap_evtchn_bind_interdomain(sender_c, channel_c, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_BZ));

  	ara_timing_info(5, 5);

	TerminateTask();
}
