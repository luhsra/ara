#include <zephyr/kernel.h>
#include <stdio.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

extern void ara_timing_info(int a, int b);

/*
 * Minimal Zephyr App
 */

void a(void* a, void* b, void* c) {
    ara_timing_info(1,2);
    printk("Hello World - A");

    // k_timeout_t t = Z_TIMEOUT_TICKS(1000);
    k_yield();
    ara_timing_info(5,6);
}

K_THREAD_DEFINE(thread_a, STACKSIZE, a, NULL, NULL, NULL,
		PRIORITY, 0, 0);
