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
	ara_timing_info(8, 12);
	TerminateTask();
}	

TASK(DRIVER_INPUT) {
	kout << "DRIVER_INPUT"<< endl;
	ara_timing_info(8, 12);
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

	ara_timing_info(2, 3);
    XEN_wrap_evtchn_bind_interdomain(REMOTE_DOMAIN, REMOTE_CHANNEL, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_HMI_UPDTE));

    // display();
	ara_timing_info(5, 10);
	TerminateTask();
}
