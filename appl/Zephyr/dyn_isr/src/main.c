
#include <zephyr.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 8)
#define PRIORITY 1
#define WORK_IRQ 0
#define WORK_IRQ_PRIORITY 1

K_THREAD_STACK_DEFINE(worker_stack_area, STACKSIZE);
struct k_thread worker;

struct k_stack work;

struct k_mutex guard;

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

struct k_mutex some_instance;

void produce_work_isr(const void* args) {
    // This isr won't work of course, it is just for testing purposes
    k_mutex_init(&some_instance);
    k_mutex_lock(&guard, K_FOREVER);
    k_stack_push(&work, (stack_data_t)0);
    k_mutex_unlock(&guard);
}

void main(void) {
    k_tid_t workerId = k_thread_create(&worker, worker_stack_area,
        STACKSIZE, do_work, NULL, NULL, NULL, PRIORITY, 0, K_FOREVER);
    
    k_stack_alloc_init(&work, MAX_WORK);
    k_mutex_init(&guard);

    irq_connect_dynamic(WORK_IRQ, WORK_IRQ_PRIORITY, produce_work_isr, NULL, 0);
    irq_enable(WORK_IRQ);
}

