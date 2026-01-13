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
channel_t channel = 42;

void event(void* a, void* b, void* c) {

  	ara_timing_info(10, 20);
    printk("Event");

}

void recv(void* a, void* b, void* c) {

  	ara_timing_info(20, 30);
    printk("B");

	XEN_wrap_evtchn_bind_interdomain(remote_dom, channel, event);

  	ara_timing_info(20, 30);
    printk("B2");

}

// lowest priority is schedueled first
K_THREAD_DEFINE(thread_a, STACKSIZE, recv, NULL, NULL, NULL,
		PRIORITY, 0, 0);

// to receive hypercalls, another IR-handling Thread is needed
// it points to the same func, as the cb in XEN_wrap_evtchn_bind_interdomain
K_THREAD_DEFINE(thread_event, STACKSIZE, event, NULL, NULL, NULL,
		PRIORITY+1, 0, -1);