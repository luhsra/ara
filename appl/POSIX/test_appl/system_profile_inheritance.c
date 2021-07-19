
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

int main() {
    pthread_attr_t attr;
    pthread_attr_init(&attr);

    struct sched_param sched_prio;
    sched_prio.sched_priority = 7;
    pthread_attr_setschedparam(&attr, &sched_prio);
    pthread_attr_setschedpolicy(&attr, SCHED_RR);
    pthread_attr_setname_np(&attr, "Test Thread");

    pthread_t new_thread;
    pthread_create(&new_thread, &attr, new_thread_routine, "test argument");
    pthread_attr_destroy(&attr);

    pthread_join(new_thread, NULL);
}