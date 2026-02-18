#include <zephyr/kernel.h>
#include <stdio.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

extern void ara_timing_info(int a, int b);

/*
 * Minimal Zephyr App
 */

void b(void* a, void* b, void* c) {
    ara_timing_info(3,4);
    printk("Hello World - B");

    // k_timeout_t t = Z_TIMEOUT_TICKS(1000);
    k_yield();
    ara_timing_info(7,8);
}

K_THREAD_DEFINE(thread_b, STACKSIZE, b, NULL, NULL, NULL,
		PRIORITY, 0, 0);
