
#define _GNU_SOURCE

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    pthread_setname_np(new_thread, "This is the threads name!");
    void* output;
    pthread_join(new_thread, &output);
}