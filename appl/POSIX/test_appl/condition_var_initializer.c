#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>

volatile bool one_second_passed = false;
pthread_cond_t one_second_cond = PTHREAD_COND_INITIALIZER;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void sleep_sec() {
    const struct timespec time = {.tv_sec = 1, .tv_nsec = 0};
    nanosleep(&time, NULL);
}

void* new_thread_routine(void* arg) {
    while (true) {
        sleep_sec();
        one_second_passed = true;
        pthread_cond_signal(&one_second_cond);
    }
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    pthread_detach(new_thread);
    while (true) {
        pthread_mutex_lock(&mutex);
        while(!one_second_passed)
            pthread_cond_wait(&one_second_cond, &mutex);
        pthread_mutex_unlock(&mutex);
        one_second_passed = false;
        puts("one second passed!");
    }
}