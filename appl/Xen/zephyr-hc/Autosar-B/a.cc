#include "autosar/os.h"
#include "xen/events.h"

DeclareTask(A);
domid_t remote_dom = 1;
channel_t channel = 42;

int main(void) {
	StartOS(0);
}

TASK(A) {
	kout << "Hello World - A" << endl;
	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	kout << "A2"<< endl;
	
	wrap_evtchn_send(channel);

	TerminateTask();
}

