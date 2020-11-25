
#include <zephyr.h>

#define STACKSIZE (1 << 10)
#define PRIORITY 1

struct work_item {
    void* reserved; // Reserved for queue management
    int data;
};

K_THREAD_STACK_DEFINE(worker_stack_area, STACKSIZE);
struct k_thread worker;

K_LIFO_DEFINE(work);

K_MUTEX_DEFINE(guard);

void do_work(void* a, void* b, void* c) {
    int done = 0;
    while(true) {
        int w = 0;
        k_mutex_lock(&guard, K_FOREVER);
        struct work_item* item = k_lifo_get(&work, K_NO_WAIT);
        k_mutex_unlock(&guard);
        done += item->data;
    }
}

void main(void) {
    k_tid_t workerId = k_thread_create(&worker, worker_stack_area,
        STACKSIZE, do_work, NULL, NULL, NULL, PRIORITY, 0, K_FOREVER);

    while(true) {
        struct work_item item = {NULL, 0};
        k_mutex_lock(&guard, K_FOREVER);
        k_lifo_put(&work, &item);
        k_mutex_unlock(&guard);
    }
}

