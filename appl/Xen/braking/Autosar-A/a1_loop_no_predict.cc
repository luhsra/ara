#include "autosar/os.h"
#include "xen/events.h"

extern "C" void ara_timing_info(int a, int b);

DeclareTask(SETUP);
DeclareTask(LOOP);
DeclareTask(OTHER);
DeclareTask(EMERGENCY);

int main(void) {
	StartOS(0);
}

domid_t zephyr_dom = 1;
channel_t channel_req = 42;
channel_t channel_emrg = 43;
EventChannelState_t e;
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
// times are annotate in TASKs
TASK(SETUP) {

	ara_timing_info(2, 3);
	// create the event channel to Zephyr
	wrap_evtchn_alloc_unbound(zephyr_dom, channel_req, nullptr);
	ara_timing_info(2, 3);
	wrap_evtchn_alloc_unbound(zephyr_dom, channel_emrg, nullptr);

	ara_timing_info(10, 12);
	ChainTask(LOOP);
}


TASK(LOOP) {

	ara_timing_info(2, 3);
	// Check if Zephyr send data
	e = wrap_evtchn_poll(channel_req, NO_BRANCH);

	// this branch we know in analysis
	if (e == PENDING_EVNT) {
		ara_timing_info(10, 11);
		read_sensors(data);
	} else {
		ara_timing_info(10, 11);
	}

	ara_timing_info(20, 21);
	read_sensors(data);

	// this branch can not be predicted by ara
	if (*(int *) data > 0) {
		ara_timing_info(10, 12);
		ActivateTask(EMERGENCY);
	}

	ara_timing_info(2, 3);
	wrap_evtchn_send(channel_req);

	ara_timing_info(2, 3);
	ChainTask(OTHER);
}

TASK(OTHER) {
	ara_timing_info(50, 50);

	// Variant: disable ChainTask to simulate one hyperperiod or a continues analysis
	ChainTask(LOOP);
}


TASK(EMERGENCY) {
	ara_timing_info(5, 10);
	wrap_evtchn_send(channel_emrg);
	ara_timing_info(100, 1000);
	// ChainTask(EMERGENCY);
	// TerminateTask();
}
