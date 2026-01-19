#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
DeclareTask(B);

// domid_t remote_dom = 1;
// channel_t channel = 42;

int main(void) {
	StartOS(0);
}

int check_adjustment() {

	ara_timing_info(10, 15);
	return 0;
}

int distance_measurement() {

	ara_timing_info(10, 15);
	return 6;
}

int process(int a, int b) {

	ara_timing_info(12, 16);
	return a + b;
}

void emergeny_braking() {

	ara_timing_info(1000, 1200);
	return 5;
}


AreaIdType area = 1;
unsigned int addr = 0x255;

TASK(B) {

	//emergeny_braking
	ara_timing_info(7, 8);
	TerminateTask();
}


TASK(A) {

	AddressType t = &addr;
	uint32_t* r;

	ara_timing_info(1, 2);
	ReadPeripheral(area, t, r);
	ara_timing_info(3, 4);

	int c = 5;
	int *cp = &c;

	// das müsste eigentlich klappen
	if (*cp < 2) {
		ActivateTask(B);
	}
	// if (*r < 10) {
	// 	ActivateTask(B);
	// }
	ara_timing_info(5, 6);

	// kout << "A"<< endl;

	// int a = check_adjustment();
	// int b = distance_measurement();

	// int c = process(a, b);


	// wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

	// ara_timing_info(40, 50);
	// kout << "A2"<< endl;

	// wrap_evtchn_send(channel);

	// ara_timing_info(20, 30);
	// kout << "A3"<< endl;

	TerminateTask();
}
// mergen

// 3 Task, 1 loop, 1x low prio request, 1x high prio braking
// get resource syscall
// GetResource/ReleaseResource
// ReadPeripheral32 WritePeripheral32