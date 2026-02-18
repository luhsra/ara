#include <zephyr/kernel.h>
#include <stdio.h>
#include "events.h" // from ara/libs/xen

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

void ara_timing_info(int a, int b);

/*
 * Send a Xen Hypercall using the Wrapper
 */

domid_t remote_dom = 0;
channel_t channel = 42;

void b(void* a, void* b, void* c) {

	ara_timing_info(10, 20);
    printk("B");

	XEN_wrap_evtchn_alloc_unbound(remote_dom, channel, NULL);

	ara_timing_info(100, 110);
    printk("B2");

	XEN_wrap_evtchn_send(channel);

	ara_timing_info(30, 40);
    printk("B3");

}

// lowest priority is schedueled first
K_THREAD_DEFINE(thread_b, STACKSIZE, b, NULL, NULL, NULL,
		PRIORITY+1, 0, 0);

