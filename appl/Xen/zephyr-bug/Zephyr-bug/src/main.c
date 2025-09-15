#include <zephyr/kernel.h>
#include <stdio.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

void ara_timing_info(int a, int b) {

}

/*
 * Minimal Zephyr App
 */

void event_rcv(void* a, void* b, void* c) {

}


void do_something(void* a, void* b, void* c) {
    int done = 0;

    ara_timing_info(10,20);

    printk("Hello");
    // k_timeout_t t = Z_TIMEOUT_TICKS(1000);
    // k_sleep(t);

    // ara_timing_info(10,50);
}

K_THREAD_DEFINE(thread_a, STACKSIZE, do_something, NULL, NULL, NULL,
		PRIORITY, 0, 0);
