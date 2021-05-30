
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
    pthread_create(&new_thread, arg, new_thread_routine2, NULL);
    void* output;
    pthread_join(new_thread, &output);
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_create(&new_thread, NULL, new_thread_routine, &attr);
    void* output;
    pthread_join(new_thread, &output);
    pthread_attr_destroy(&attr);
}