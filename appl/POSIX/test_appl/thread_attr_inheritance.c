
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine_2(void* arg) {
    puts("new_thread_routine_2");
    pause();
    return NULL;
}

void* new_thread_routine_3(void* arg) {
    puts("new_thread_routine_3");
    pause();
    return NULL;
}

void init_thread_attr(pthread_attr_t* attr, struct sched_param* sched_prio) {
    pthread_attr_init(attr);

    sched_prio->sched_priority = 0;
    pthread_attr_setschedparam(attr, sched_prio);

    pthread_attr_setschedpolicy(attr, SCHED_OTHER);
    pthread_attr_setname_np(attr, "Test Thread");
}

void* new_thread_routine_1(void* arg) {
    puts("new_thread_routine_1");

    pthread_attr_t attr_1;
    struct sched_param sched_prio_1;
    init_thread_attr(&attr_1, &sched_prio_1);
    pthread_attr_setinheritsched(&attr_1, PTHREAD_INHERIT_SCHED);

    pthread_attr_t attr_2;
    struct sched_param sched_prio_2;
    init_thread_attr(&attr_2, &sched_prio_2);
    pthread_attr_setinheritsched(&attr_2, PTHREAD_EXPLICIT_SCHED);

    pthread_t new_thread_1;
    pthread_t new_thread_2;
    pthread_create(&new_thread_1, &attr_1, new_thread_routine_2, "test argument");
    pthread_create(&new_thread_2, &attr_2, new_thread_routine_3, "test argument");

    pthread_attr_destroy(&attr_1);
    pthread_attr_destroy(&attr_2);

    void* output;
    pthread_join(new_thread_1, &output);
    pthread_join(new_thread_2, &output);
    return NULL;
}

int main() {
    pthread_attr_t attr;
    pthread_attr_init(&attr);

    struct sched_param sched_prio;
    sched_prio.sched_priority = 8;
    pthread_attr_setschedparam(&attr, &sched_prio);

    pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
    pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
    pthread_attr_setname_np(&attr, "Inheritance Thread");

    pthread_t new_thread;
    pthread_create(&new_thread, &attr, new_thread_routine_1, "test argument");
    pthread_attr_destroy(&attr);

    void* output;
    pthread_join(new_thread, &output);
}