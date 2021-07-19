
#define _GNU_SOURCE

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

int main(int argc, char** argv) {
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
    struct sched_param sched_prio;
    sched_prio.sched_priority = 7;
    pthread_attr_setschedparam(&attr, &sched_prio);
    pthread_attr_setschedpolicy(&attr, SCHED_RR);
    pthread_attr_setname_np(&attr, "Test Thread");
    pthread_t new_thread;
    pthread_create(&new_thread, &attr, new_thread_routine, "test argument");

    if (argc > 2)
        pthread_setname_np(new_thread, "This is the threads name!");

    void* output;
    pthread_join(new_thread, &output);
    pthread_attr_destroy(&attr);
}