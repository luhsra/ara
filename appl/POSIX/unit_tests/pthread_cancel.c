
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void _sleep(time_t sec) {
    const struct timespec time = {.tv_sec = sec, .tv_nsec = 0};
    nanosleep(&time, NULL);
}

void* new_thread_routine(void* arg) {
    while (1) {
        puts("one second passed!");
        _sleep(1);
    }
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    pthread_detach(new_thread);
    _sleep(5);
    pthread_cancel(new_thread);
    _sleep(5);
}