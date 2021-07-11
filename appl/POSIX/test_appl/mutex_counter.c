
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

volatile unsigned long long counter = 0;
pthread_mutex_t mutex;

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    for (int i = 0; i < 200; ++i) {
        pthread_mutex_lock(&mutex);
        ++counter;
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_mutex_init(&mutex, NULL);
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    for (int i = 0; i < 100; ++i) {
        pthread_mutex_lock(&mutex);
        ++counter;
        pthread_mutex_unlock(&mutex);
    }
    printf("counter is %d\n", counter);
    void* output;
    pthread_join(new_thread, &output);
    printf("counter is %d\n", counter); // should be 300
}