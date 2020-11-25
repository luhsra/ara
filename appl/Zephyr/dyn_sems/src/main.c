/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <sys/printk.h>

#define STACKSIZE 1024

#define PRIORITY 7

#define SLEEPTIME 500


void helloLoop(const char *my_name,
	       struct k_sem *my_sem, struct k_sem *other_sem)
{
    const char *tname;

    while (1) {
        k_sem_take(my_sem, K_FOREVER);

        tname = k_thread_name_get(k_current_get());
        if (tname != NULL && tname[0] != '\0') {
            printk("%s: Hello World from %s!\n",
                        tname, CONFIG_BOARD);
        } else {
            printk("%s: Hello World from %s!\n",
                    my_name, CONFIG_BOARD);
        }

        k_msleep(SLEEPTIME);
        k_sem_give(other_sem);
    }
}

struct k_sem threadA_sem, threadB_sem;

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

    k_sem_init(&threadA_sem, 1, 1);
    k_sem_init(&threadB_sem, 0, 1);

    k_tid_t tid = k_thread_create(&threadB_data, threadB_stack_area,
                    STACKSIZE, threadB, NULL, NULL, NULL,
                    PRIORITY, 0, K_NO_WAIT);

    k_thread_name_set(tid, "thread_b");

    helloLoop(__func__, &threadA_sem, &threadB_sem);
}


K_THREAD_STACK_DEFINE(threadA_stack_area, STACKSIZE);
struct k_thread threadA_data;

void main(void)
{ 
    k_tid_t tid = k_thread_create(&threadA_data, threadA_stack_area,
                    STACKSIZE, threadA, NULL, NULL, NULL,
                    PRIORITY, 0, K_NO_WAIT);
    
    k_thread_name_set(tid, "thread_a");
}


