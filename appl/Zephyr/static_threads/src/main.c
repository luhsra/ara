
#include <zephyr.h>

#define STACKSIZE 1024

#define PRIORITY 7

#define SLEEPTIME 500

struct k_sem my_sem;

k_tid_t my_id;
void do_stuff(void *dummy1, void *dummy2, void *dummy3)
{
	ARG_UNUSED(dummy1);
	ARG_UNUSED(dummy2);
	ARG_UNUSED(dummy3);
    /*my_id = k_current_get();
    k_wakeup(my_id);
    while(true){
        volatile int stuff = 0;
        k_msleep(500);
        k_yield();
    }*/
    k_sem_init(&my_sem, 0, 1);
}

void do_stuff2(void *dummy1, void *dummy2, void *dummy3)
{
	ARG_UNUSED(dummy1);
	ARG_UNUSED(dummy2);
	ARG_UNUSED(dummy3);
        while(true){
            volatile int stuff = 0;
            k_msleep(500);
            k_yield();
        }
}

void do_stuff3(void *dummy1, void *dummy2, void *dummy3)
{
    do_stuff(dummy1, dummy2, dummy3);
}

K_THREAD_DEFINE(thread_a, STACKSIZE, do_stuff, NULL, NULL, NULL,
		PRIORITY, 0, 0);


K_THREAD_DEFINE(thread_b, STACKSIZE, do_stuff, NULL, NULL, NULL,
		PRIORITY + 4, 0, 0);


