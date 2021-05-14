

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine(void* arg) {
    pause();
    return NULL;
}

int main() {
    pthread_t super_thread;
    new_thread_routine(NULL);
    pthread_create(&super_thread, NULL, new_thread_routine, NULL);
}