
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

int main() {
    pthread_t super_thread;
    pthread_create(&super_thread, NULL, new_thread_routine, "test argument");
    void* output;
    pthread_join(super_thread, &output);
}