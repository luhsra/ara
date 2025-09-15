#include <zephyr/kernel.h>
#include <stdio.h>
#include <zephyr/events.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

/*
 * Send a Xen Hypercall using the Wrapper
 */

domid_t remote_dom = 0;
channel_t channel = 42;

void event_rcv() {

}

void recv(void* a, void* b, void* c) {
    int done = 0;
    printk("Hello");
    k_tid_t x;
    x = k_current_get();
    printk(x);

	wrap_evtchn_bind_interdomain(remote_dom, channel, event_rcv);

	// XEN_wrap_evtchn_alloc_unbound(remote_dom, channel, NULL);
	// XEN_wrap_evtchn_send(channel);

    k_timeout_t t = Z_TIMEOUT_TICKS(1000);
    k_sleep(t);

}


K_THREAD_DEFINE(thread_a, STACKSIZE, recv, NULL, NULL, NULL,
		PRIORITY, 0, 0);
