
#include <zephyr.h>

#define STACKSIZE (1 << 10)
#define MAX_WORK (1 << 8)
#define PRIORITY 1

struct k_sem sem0;
K_SEM_DEFINE(sem1, 0, 1);

void thread_a(void* a, void* b, void* c) {
    k_sem_init(&sem0, 1, 2);
    k_sem_init(&sem1, 0, 5);
}

K_THREAD_DEFINE(threadA, STACKSIZE, thread_a, NULL, NULL, NULL, PRIORITY, 0, 0);


void main(void) {
    k_sem_init(&sem0, 0, 1);
    k_sem_take(&sem0, K_FOREVER);
    k_sem_take(&sem1, K_FOREVER);
}
