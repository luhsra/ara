
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void* new_thread_routine(void* arg) {
    pthread_mutex_unlock(&mutex);
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    pthread_mutex_lock(&mutex);
    void* output;
    pthread_join(new_thread, &output);
    printf("new_thread_routine successfully returned.\n");
}