
#include <zephyr.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 8)
#define PRIORITY 1
#define WORK_IRQ 0
#define WORK_IRQ_PRIORITY 1

K_THREAD_STACK_DEFINE(worker_stack_area, STACKSIZE);
struct k_thread worker;

K_STACK_DEFINE(work, MAX_WORK);

K_MUTEX_DEFINE(guard);

void do_work(void* a, void* b, void* c) {
    int done = 0;
    while(true) {
        int w = 0;
        k_mutex_lock(&guard, K_FOREVER);
        k_stack_pop(&work, (stack_data_t*)w, K_NO_WAIT);
        k_mutex_unlock(&guard);
        done += w;
    }
}

void produce_work_isr(const void* args) {
    // This isr won't work of course, it is just for testing purposes
    k_mutex_lock(&guard, K_FOREVER);
    k_stack_push(&work, (stack_data_t)0);
    k_mutex_unlock(&guard);
}

void produce_more_work_isr(const void* args) {
    // This isr won't work of course, it is just for testing purposes
    if (k_is_in_isr()){
        k_mutex_lock(&guard, K_FOREVER);
        k_stack_push(&work, (stack_data_t)1);
        k_mutex_unlock(&guard);
    }
}

void main(void) {
    k_tid_t workerId = k_thread_create(&worker, worker_stack_area,
        STACKSIZE, do_work, NULL, NULL, NULL, PRIORITY, 0, K_FOREVER);

    while(true) {
        k_mutex_lock(&guard, K_FOREVER);
        k_stack_push(&work, (stack_data_t)0);
        k_mutex_unlock(&guard);
    }

    IRQ_CONNECT(WORK_IRQ, WORK_IRQ_PRIORITY, produce_work_isr, NULL, 0);
    IRQ_DIRECT_CONNECT(WORK_IRQ + 1, WORK_IRQ_PRIORITY + 1, produce_more_work_isr, 0);
    irq_enable(WORK_IRQ);
    irq_enable(WORK_IRQ + 1);
}

