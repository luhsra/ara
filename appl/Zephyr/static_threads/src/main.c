
#include <zephyr.h>

#define STACKSIZE 1024

#define PRIORITY 7

#define SLEEPTIME 500

void zephyr_dummy_syscall(){};

void do_stuff(void *dummy1, void *dummy2, void *dummy3)
{
	ARG_UNUSED(dummy1);
	ARG_UNUSED(dummy2);
	ARG_UNUSED(dummy3);
        zephyr_dummy_syscall();
        while(true){
            volatile int stuff = 0;
            k_msleep(500);
            k_yield();
        }
}

K_THREAD_DEFINE(thread_a, STACKSIZE, do_stuff, NULL, NULL, NULL,
		PRIORITY, 0, 0);


K_THREAD_DEFINE(thread_b, STACKSIZE, do_stuff, NULL, NULL, NULL,
		PRIORITY + 4, 0, 0);

void main() {
    zephyr_dummy_syscall();
}
