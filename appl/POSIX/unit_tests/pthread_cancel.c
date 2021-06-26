
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine(void* arg) {
    while (1) {
        puts("one second passed!");
        sleep(1);
    }
    return NULL;
}

int main() {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    pthread_detach(new_thread);
    sleep(5);
    pthread_cancel(new_thread);
    sleep(5);
}