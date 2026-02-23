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

	ara_timing_info(1, 1);
	// create the event channel to Zephyr
	wrap_evtchn_alloc_unbound(zephyr_dom, channel_req, nullptr);
	wrap_evtchn_alloc_unbound(zephyr_dom, channel_emrg, nullptr);

	ara_timing_info(2, 2);
	ChainTask(LOOP);
}


TASK(LOOP) {

	ara_timing_info(3, 3);
	// Check if Zephyr send data
	e = wrap_evtchn_poll(channel_req, IS_BRANCH);

	// this branch we know in analysis
	if (e == PENDING_EVNT) {
		ara_timing_info(4, 4);
		read_sensors(data);
	} else {
		ara_timing_info(4, 4);
	}

	ara_timing_info(6, 6);
	read_sensors(data);

	// this branch can not be predicted by ara
	if (*(int *) data > 0) {
		ara_timing_info(10, 10);
		ActivateTask(EMERGENCY);
	}

	ara_timing_info(7, 7);
	wrap_evtchn_send(channel_req);

	ara_timing_info(8, 8);
	ChainTask(OTHER);
}

TASK(OTHER) {
	ara_timing_info(1000, 1000);

	// Variant: disable ChainTask to simulate one hyperperiod or a continues analysis
	ChainTask(LOOP);
}


TASK(EMERGENCY) {
	ara_timing_info(100, 100);
	wrap_evtchn_send(channel_emrg);
	ara_timing_info(100, 100);
	// ChainTask(EMERGENCY);
	// TerminateTask();
}
