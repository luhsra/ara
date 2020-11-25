
#include <zephyr.h>
#include <sys/printk.h>
//#include "printer.h"

#define STACKSIZE 1024

#define PRIORITY 7

#define SLEEPTIME 500

void threadA(void *dummy1, void *dummy2, void *dummy3)
{
	ARG_UNUSED(dummy1);
	ARG_UNUSED(dummy2);
	ARG_UNUSED(dummy3);
	arch_cpu_idle();
	while(true) {
		printk("Hello");
	}
}

K_THREAD_DEFINE(thread_a, STACKSIZE, threadA, NULL, NULL, NULL,
		PRIORITY, 0, 0);
