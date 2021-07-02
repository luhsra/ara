#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t mutex;
pthread_t new_thread;

void* new_thread_routine(void *arg) {
    pthread_mutex_unlock(&mutex);
    return NULL;
}

void init_mutex(pthread_mutex_t *mutex) {
    pthread_mutex_init(mutex, NULL);
    pthread_mutex_lock(mutex);
}

int main() {
    init_mutex(&mutex);
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    pthread_join(new_thread, NULL);
    printf("new_thread_routine successfully returned.\n");
}