#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(SETUP);
DeclareTask(CALC);
DeclareTask(EMERGENCY);

int main(void) {
	StartOS(0);
}

// HELPER

domid_t autosar_dom = 0;
channel_t channel_req = 42;
channel_t channel_emrg = 43;
void* data;

void manip(void* data, void* some) {

	// include some into data

	return;
}

void read_sensors(void * data) {

	AreaIdType area = 1;
	unsigned int addr = 0x255;
	AddressType t = &addr;
	void * local = nullptr;

	ReadPeripheral(area, t, (ReadValueType)local);

	manip(data, local);

	return;
}


// TASKS


// TASK(LOOP) {

// 	ara_timing_info(5, 6);
// 	// Check if Zephyr send data
// 	e = wrap_evtchn_poll(channel_req);

// 	// this branch we know in analysis
// 	if (e == PENDING_EVNT) {
// 		ara_timing_info(7, 8);
// 		read_sensors(data);
// 	} else {
		
// 	}

// 	ara_timing_info(9, 10);
// 	read_sensors(data);

// 	// this branch can not be predicted by ara
// 	if (*(int *) data > 0) {
// 		ara_timing_info(11, 12);
// 		ActivateTask(EMERGENCY);
// 	}

// 	ara_timing_info(13, 14);
// 	wrap_evtchn_send(channel_emrg);

// 	ara_timing_info(15, 16);
// 	ChainTask(OTHER);
// }

TASK(CALC) {
	ara_timing_info(25, 25);

	// Variant: send an ACK from Zephyr -> creates more SPs
	// wrap_evtchn_send(channel_req);

	TerminateTask();
}

TASK(EMERGENCY) {
	ara_timing_info(100, 100);
	ChainTask(EMERGENCY);
}

TASK(SETUP) {

	ara_timing_info(1, 2);
	// create the event channel to Zephyr
	wrap_evtchn_alloc_unbound(autosar_dom, channel_req, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_CALC));
	wrap_evtchn_alloc_unbound(autosar_dom, channel_emrg, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_EMERGENCY));

	ara_timing_info(3, 4);
	TerminateTask();
}
// TASK(A) {

// 	int adj = 0;
// 	int *adj_p = &adj;
// 	request_speed_adjustment(adj_p);


// 	AddressType t = &addr;
// 	// Careful, always assign var
// 	ReadValueType r = 0;
// 	StatusType s;

// 	ara_timing_info(1, 2);
// 	s = ReadPeripheral(area, t, r);
// 	ara_timing_info(3, 4);

// 	// int c = 5;
// 	// int *cp = &c;

// 	// das müsste eigentlich klappen
// 	// if (*cp > 2) {
// 	// 	ActivateTask(B);
// 	// }
// 	if (*r <= 10) {
// 		ara_timing_info(9, 10);
// 		ActivateTask(B);
// 	} else {
// 		ara_timing_info(13, 17);
// 	}
// 	ara_timing_info(5, 6);

// 	// kout << "A"<< endl;

// 	// int a = check_adjustment();
// 	// int b = distance_measurement();

// 	// int c = process(a, b);


// 	// wrap_evtchn_alloc_unbound(remote_dom, channel, nullptr);

// 	// ara_timing_info(40, 50);
// 	// kout << "A2"<< endl;

// 	// wrap_evtchn_send(channel);

// 	// ara_timing_info(20, 30);
// 	// kout << "A3"<< endl;

// 	TerminateTask();
// }
