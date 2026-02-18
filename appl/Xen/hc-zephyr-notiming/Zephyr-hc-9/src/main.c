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

domid_t remote_dom = 1;
channel_t channel = 42;

void a(void* a, void* b, void* c) {

	ara_timing_info(10, 20);
    printk("A");

	XEN_wrap_evtchn_alloc_unbound(remote_dom, channel, NULL);

	ara_timing_info(100, 110);
    printk("A2");

	XEN_wrap_evtchn_send(channel);

	ara_timing_info(30, 40);
    printk("A3");

}

K_THREAD_DEFINE(thread_a, STACKSIZE, a, NULL, NULL, NULL,
		PRIORITY, 0, 0);
