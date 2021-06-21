#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* new_thread_routine(void* arg) {
    printf("arg = \"%s\"\n", (char*)arg);
    pause();
    return NULL;
}

struct ThreadStruct {
    void* (*new_thread_routine)(void* arg);
};

struct ThreadStruct thread_struct;

void caller(struct ThreadStruct* ptr) {
    pthread_t new_thread;
    pthread_create(&new_thread, NULL, ptr->new_thread_routine, "test argument");
}

int main() {
    struct ThreadStruct* ptr = &thread_struct;
    ptr->new_thread_routine = new_thread_routine;
    caller(ptr);
}