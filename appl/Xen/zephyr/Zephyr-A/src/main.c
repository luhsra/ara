#include <zephyr/kernel.h>
#include <stdio.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 2)
#define PRIORITY 1

/*
 * Minimal Zephyr App
 */

void calc(void* a, void* b, void* c) {
    int done = 0;
    printk("Hello");
    k_timeout_t t = Z_TIMEOUT_TICKS(1000);
    k_sleep(t);
}

K_THREAD_DEFINE(thread_a, STACKSIZE, calc, NULL, NULL, NULL,
		PRIORITY, 0, 0);
