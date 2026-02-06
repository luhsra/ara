#include <zephyr/kernel.h>
#include <stdio.h>
#include "../../ara/libs/xen/events.h"

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

void ara_timing_info(int a, int b);

// HELPER
typedef uint32_t AreaIdType;
typedef const uint32_t* AddressType;
typedef uint32_t* ReadValueType;
domid_t autosar_dom = 1;
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
	void * local = NULL;

	manip(data, local);
	return;
}


// TASKS
void calc(void* a, void* b, void* c) {

	ara_timing_info(11, 11);
	read_sensors(data);

	// Send ACK here
	ara_timing_info(12, 12);
	XEN_wrap_evtchn_send(channel_req);
	// Update Linux
	ara_timing_info(12, 12);
	XEN_wrap_evtchn_send(channel_hmi);

	ara_timing_info(13, 13);
	return;
}

void emergency(void* a, void* b, void* c) {

  	ara_timing_info(100, 100);

	return;
}

void setup(void* a, void* b, void* c) {

	ara_timing_info(1, 1);
	// create the event channel to Zephyr
	XEN_wrap_evtchn_alloc_unbound(autosar_dom, channel_req, calc);
	XEN_wrap_evtchn_alloc_unbound(autosar_dom, channel_emrg, emergency);
	XEN_wrap_evtchn_alloc_unbound(agl_dom, channel_hmi, NULL);

	ara_timing_info(2, 2);
	return;

}

// lowest priority is schedueled first
K_THREAD_DEFINE(thread_a, STACKSIZE, setup, NULL, NULL, NULL,
		PRIORITY+1, 0, 0);

K_THREAD_DEFINE(thread_event_calc, STACKSIZE, calc, NULL, NULL, NULL,
		PRIORITY, 0, -1);

K_THREAD_DEFINE(thread_event_emergency, STACKSIZE, emergency, NULL, NULL, NULL,
		PRIORITY, 0, -1);
