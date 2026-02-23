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
domid_t agl_dom = 2;
channel_t channel_req = 42;
channel_t channel_emrg = 43;
channel_t channel_hmi = 44;
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
TASK(CALC) {
	ara_timing_info(8, 11);
	read_sensors(data);

	// Send ACK here
	ara_timing_info(2, 3);
	wrap_evtchn_send(channel_req);
	// Update Linux
	ara_timing_info(2, 3);
	wrap_evtchn_send(channel_hmi);

	ara_timing_info(1, 2);
	TerminateTask();
}

TASK(EMERGENCY) {
  	ara_timing_info(10, 100);

	while (true){}
	
	// ChainTask(EMERGENCY);
	// TerminateTask();
}

TASK(SETUP) {

	ara_timing_info(2, 3);
	// create the event channel to Zephyr
	wrap_evtchn_alloc_unbound(autosar_dom, channel_req, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_CALC));
	ara_timing_info(2, 3);
	wrap_evtchn_alloc_unbound(autosar_dom, channel_emrg, reinterpret_cast<void*>(AUTOSAR_TASK_FUNC_EMERGENCY));
	ara_timing_info(2, 3);
	wrap_evtchn_alloc_unbound(agl_dom, channel_hmi, nullptr);

	ara_timing_info(1, 2);
	TerminateTask();
}
