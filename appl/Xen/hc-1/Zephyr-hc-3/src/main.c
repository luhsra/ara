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

void sender(void* a, void* b, void* c) {

	ara_timing_info(40, 50);
  printk("A");

	XEN_wrap_evtchn_alloc_unbound(remote_dom, channel, NULL);

	ara_timing_info(40, 50);
  printk("A2");

	XEN_wrap_evtchn_send(channel);

	ara_timing_info(20, 30);
  printk("A3");

}

K_THREAD_DEFINE(thread_a, STACKSIZE, sender, NULL, NULL, NULL,
		PRIORITY+1, 0, 0);
