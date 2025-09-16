#include <zephyr/kernel.h>
#include <stdio.h>
#include <zephyr/events.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

void ara_timing_info(int a, int b);

/*
 * Send a Xen Hypercall using the Wrapper
 */

domid_t remote_dom = 0;
channel_t channel = 42;

void dummy_event_rcv(void* a, void* b, void* c) {

  	// ara_timing_info(5, 7);
    // printk("Hello");
    // k_tid_t x;
    // x = k_current_get();
    // printk(x);
  	ara_timing_info(6, 8);
    printk("Hello");
}

void recv(void* a, void* b, void* c) {

  	ara_timing_info(20, 30);
    printk("B");

    // k_tid_t x;
    // x = k_current_get();
    // printk(x);
  	// ara_timing_info(5, 10);

    XEN_wrap_evtchn_bind_interdomain(remote_dom, channel, dummy_event_rcv);


  	ara_timing_info(20, 30);

}

K_THREAD_DEFINE(thread_a, STACKSIZE, recv, NULL, NULL, NULL,
		PRIORITY+4, 0, 0);

// to receive hypercalls, we need another IR-Handler Thread, that holds the same func, as the cb!
K_THREAD_DEFINE(thread_event, STACKSIZE, dummy_event_rcv, NULL, NULL, NULL,
		PRIORITY, 0, -1);