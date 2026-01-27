#include <zephyr/kernel.h>
#include <stdio.h>
#include "../../../events.h"

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

void ara_timing_info(int a, int b);

/*
 * Send a Xen Hypercall using the Wrapper
 */

domid_t remote_dom = 0;
channel_t channel_req = 42;
channel_t channel_emrg = 43;

void calc(void* a, void* b, void* c) {

  	ara_timing_info(100, 100);
    printk("Read-Sensors");
    printk("Check pending User Overwrite");
    printk("Apply");

}

void emergency_brake(void* a, void* b, void* c) {

  	ara_timing_info(100, 100);
    printk("Braaaking");

}

void recv(void* a, void* b, void* c) {

  	ara_timing_info(20, 30);
    printk("B");

	XEN_wrap_evtchn_bind_interdomain(remote_dom, channel_req, calc);
	XEN_wrap_evtchn_bind_interdomain(remote_dom, channel_emrg, emergency_brake);

  	// ara_timing_info(20, 30);
    // printk("B2");

}

// lowest priority is schedueled first
K_THREAD_DEFINE(thread_a, STACKSIZE, recv, NULL, NULL, NULL,
		PRIORITY+1, 0, 0);

// to receive hypercalls, another IR-handling Thread is needed
// it points to the same func, as the cb in XEN_wrap_evtchn_bind_interdomain
K_THREAD_DEFINE(thread_event, STACKSIZE, emergency_brake, NULL, NULL, NULL,
		PRIORITY, 0, -1);

K_THREAD_DEFINE(thread_event2, STACKSIZE, calc, NULL, NULL, NULL,
		PRIORITY, 0, -1);