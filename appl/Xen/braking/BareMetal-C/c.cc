#include "autosar/os.h"
#include "xen/events.h"

// AUTOSAR and not BareMetal !!!

extern "C" void ara_timing_info(int a, int b);

DeclareTask(SETUP);
DeclareTask(HMI_UPDTE);
DeclareTask(CALC);

int main(void) {
	StartOS(0);
}

TASK(HMI_UPDTE) {
	kout << "HMI_UPDTE"<< endl;
	ara_timing_info(5, 5);
	TerminateTask();
}	

TASK(DRIVER_INPUT) {
	kout << "DRIVER_INPUT"<< endl;
	ara_timing_info(10, 10);
	TerminateTask();
}	

// void display() {
//     return;
// }

TASK(SETUP) {   

    int remote_domain;
    remote_domain = 1;
	domid_t REMOTE_DOMAIN = remote_domain;
	channel_t REMOTE_CHANNEL = 44;

	ara_timing_info(5, 5);
    XEN_wrap_evtchn_bind_interdomain(REMOTE_DOMAIN, REMOTE_CHANNEL, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_HMI_UPDTE));

	// ara_timing_info(6, 6);
    // printf("Binder is done, handler was forked.\n");
    // display();
	ara_timing_info(3, 3);
	TerminateTask();
}
