/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <sys/printk.h>
#include <sys/sem.h>

#define STACKSIZE 1024

#define PRIORITY 7

#define SLEEPTIME 500

void helloLoop(const char *my_name,
	       struct sys_sem *my_sem, struct sys_sem *other_sem)
{
	const char *tname;

	while (1) {
		sys_sem_take(my_sem, K_FOREVER);

		tname = k_thread_name_get(k_current_get());
		if (tname != NULL && tname[0] != '\0') {
			printk("%s: Hello World from %s!\n",
				tname, CONFIG_BOARD);
		} else {
			printk("%s: Hello World from %s!\n",
				my_name, CONFIG_BOARD);
		}

		k_msleep(SLEEPTIME);
		sys_sem_give(other_sem);
	}
}

SYS_SEM_DEFINE(threadA_sem, 1, 1);
SYS_SEM_DEFINE(threadB_sem, 0, 1);


void threadB(void *dummy1, void *dummy2, void *dummy3)
{
	ARG_UNUSED(dummy1);
	ARG_UNUSED(dummy2);
	ARG_UNUSED(dummy3);

	helloLoop(__func__, &threadB_sem, &threadA_sem);
}

K_THREAD_STACK_DEFINE(threadB_stack_area, STACKSIZE);
static struct k_thread threadB_data;

void threadA(void *dummy1, void *dummy2, void *dummy3)
{
	ARG_UNUSED(dummy1);
	ARG_UNUSED(dummy2);
	ARG_UNUSED(dummy3);

	k_tid_t tid = k_thread_create(&threadB_data, threadB_stack_area,
			STACKSIZE, threadB, NULL, NULL, NULL,
			PRIORITY, 0, K_NO_WAIT);

	k_thread_name_set(tid, "thread_b");

	helloLoop(__func__, &threadA_sem, &threadB_sem);
}

K_THREAD_DEFINE(thread_a, STACKSIZE, threadA, NULL, NULL, NULL,
		PRIORITY, 0, 0);

void main() {
    k_thread_join(thread_a, K_FOREVER);
    k_thread_join(&threadB_data, K_FOREVER);
}

