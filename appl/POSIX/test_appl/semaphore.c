
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <semaphore.h>

sem_t semaphore;

void* new_thread_routine(void* arg) {
    sem_post(&semaphore);
    return NULL;
}

int main() {
    sem_init(&semaphore, 1, 1);
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, new_thread_routine, "test argument");
    sem_wait(&semaphore);
    void* output;
    pthread_join(new_thread, &output);
    printf("new_thread_routine successfully returned.\n");
}