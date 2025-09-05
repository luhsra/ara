#include "autosar/os.h"
#include "xen/events.h"

DeclareTask(A);
domid_t remote_dom = 0;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(IR) {
	kout << "hello" << endl;
	TerminateTask();
}

TASK(A) {
	wrap_evtchn_bind_interdomain(remote_dom, channel, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_IR));

	TerminateTask();
}

