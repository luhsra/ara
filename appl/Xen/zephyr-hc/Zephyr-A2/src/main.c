#include <zephyr/kernel.h>
#include <stdio.h>
#include "events.h"

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

/*
 * Send a Xen Hypercall using the Wrapper
 */

K_MSGQ_DEFINE(work, sizeof(int), MAX_WORK, 4);

domid_t remote_dom = 0;
channel_t channel = 42;

void sender(void* a, void* b, void* c) {
    printk("Hello");
    int w = 0;
    k_tid_t x = k_current_get();

    int done = 0;
	// wrap_evtchn_alloc_unbound(remote_dom, channel, NULL);
	// wrap_evtchn_send(channel);

    printk("Hello");
    k_msgq_get(&work, &w, K_FOREVER);
}


K_THREAD_DEFINE(thread_a, STACKSIZE, sender, NULL, NULL, NULL,
		PRIORITY, 0, 0);
