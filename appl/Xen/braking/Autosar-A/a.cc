#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(A);
DeclareTask(B);


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


int request_speed_adjustment(int * adj_p) {

	ara_timing_info(12, 16);
	return a + b;
}

void setup() {

	ara_timing_info(1, 2);
	wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);
	ara_timing_info(3, 4);

	return;
}

TASK(SETUP) {

	domid_t zephyr_dom = 1;
	channel_t channel = 42;

}
TASK(WAITING) {

}

TASK(LOOP) {

}

TASK(EMERGENCY) {

}

TASK(A) {

	int adj = 0;
	int *adj_p = &adj;
	request_speed_adjustment(adj_p)


	AddressType t = &addr;
	// Careful, always assign var
	ReadValueType r = 0;
	StatusType s;

	ara_timing_info(1, 2);
	s = ReadPeripheral(area, t, r);
	ara_timing_info(3, 4);

	// int c = 5;
	// int *cp = &c;

	// das müsste eigentlich klappen
	// if (*cp > 2) {
	// 	ActivateTask(B);
	// }
	if (*r <= 10) {
		ara_timing_info(9, 10);
		ActivateTask(B);
	} else {
		ara_timing_info(13, 17);
	}
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