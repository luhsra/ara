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

void do_something(void* a, void* b, void* c) {

    ara_timing_info(10,20);
    k_tid_t x;

    // Working system call
    x = k_current_get();

    ara_timing_info(10,20);
    printk(x);  // need print here!
    k_timeout_t t = Z_TIMEOUT_TICKS(1000);

    // first sleep works
    k_sleep(t);
    
    // TODO: does not continue here!
    ara_timing_info(10,20);
    printk("End1");
    
    k_sleep(t);
    
    ara_timing_info(10,20);
    printk("End2");
}

K_THREAD_DEFINE(thread_a, STACKSIZE, do_something, NULL, NULL, NULL,
		PRIORITY, 0, 0);
