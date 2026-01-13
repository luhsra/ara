#include "autosar/os.h"
#include "test/test.h"
#include "xen/events.h"

DeclareTask(T30);
DeclareTask(T30PREP);

extern "C" void ara_timing_info(int a, int b);

domid_t remote_a = 0;
domid_t remote_b = 1;
domid_t remote_c = 2;
domid_t remote_d = 3;
channel_t channel_a_b = 30;
channel_t channel_a_c = 40;
channel_t channel_a_d = 50;

int main(void) {
	StartOS(0);
}

TASK(T30) {
	test_trace('1');
  	ara_timing_info(30, 30);
	TerminateTask();
}

TASK(T30PREP) {

  	ara_timing_info(5, 5);
	wrap_evtchn_bind_interdomain(remote_a, channel_a_d, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_T30));

	TerminateTask();
}

