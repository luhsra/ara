
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
    void* output;
    pthread_join(new_thread, &output);
}