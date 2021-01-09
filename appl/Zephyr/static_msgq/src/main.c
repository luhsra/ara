
#include <zephyr.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 8)
#define PRIORITY 1

K_THREAD_STACK_DEFINE(worker_stack_area, STACKSIZE);
struct k_thread worker;

K_MSGQ_DEFINE(work, sizeof(int), MAX_WORK, 4);
K_MUTEX_DEFINE(guard);

void do_work(void* a, void* b, void* c) {
    int done = 0;
    while(true) {
        if (k_msgq_num_used_get(&work) == MAX_WORK * sizeof(int)) continue;
        int w = 0;
        k_mutex_lock(&guard, K_FOREVER);
        k_msgq_get(&work, &w, K_NO_WAIT);
        k_mutex_unlock(&guard);
        done += w;
    }
}

void main(void) {
    k_tid_t workerId = k_thread_create(&worker, worker_stack_area,
        STACKSIZE, do_work, NULL, NULL, NULL, PRIORITY, 0, K_FOREVER);
    int item = 0;
    while(true) {
        k_mutex_lock(&guard, K_FOREVER);
        k_msgq_put(&work, &item, K_NO_WAIT);
        k_mutex_unlock(&guard);
    }
}

