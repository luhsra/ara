
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine2(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

void* new_thread_routine(void* arg) {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, new_thread_routine2, arg);
    void* output;
    pthread_join(new_thread, &output);
    return NULL;
}

int main() {
    pthread_t new_thread;
    char* arg = "Thread argument.";
    pthread_create(&new_thread, NULL, new_thread_routine, arg);
    void* output;
    pthread_join(new_thread, &output);
}